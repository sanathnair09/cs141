use core::time;
use std::collections::HashMap;
use std::fs::{File, OpenOptions};
use std::io::Write;
use std::io::{BufRead, BufReader};
use std::sync::{Arc, Condvar, Mutex};
use std::thread::JoinHandle;
use std::{env, thread};

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 4 {
        panic!("Incorrect number of arguments");
    }

    let num_of_users: u32 = str::parse(&args[1][1..]).expect("Expected arg in format -#");
    let num_of_disks: u32 = str::parse(&args[2][1..]).expect("Expected arg in format -#");
    let num_of_printers: u32 = str::parse(&args[3][1..]).expect("Expected arg in format -#");

    let mut handles: Vec<JoinHandle<()>> = Vec::with_capacity(num_of_users as usize);

    // Arc (Atomic reference counted) - thread safe refernce counting pointer
    // allows us to create multiple owners of the same data

    // Mutex - locks the resource to whatever thread requested and prevents others from manipulating it

    let d_manager = Arc::new(Mutex::new(DiskManager::new(num_of_disks)));
    let p_manager = Arc::new(Mutex::new(PrinterManager::new(num_of_printers)));

    // needed to implement wait and notify
    let free_disks = Arc::new((
        Mutex::new(vec![true; num_of_disks as usize]),
        Condvar::new(), // condvar needed to pause and notify other threads of changes to the disks
    ));

    let free_printers = Arc::new((
        Mutex::new(vec![true; num_of_printers as usize]),
        Condvar::new(),
    ));

    for i in 0..num_of_users {
        // sharing the object amongst all users
        let cloned_d_manager = Arc::clone(&d_manager);
        let cloned_p_manager = Arc::clone(&p_manager);
        let free_disks_clone = Arc::clone(&free_disks);
        let free_printers_clone = Arc::clone(&free_printers);

        handles.push(thread::spawn(move || {
            UserThread::new(
                i,
                cloned_d_manager,
                cloned_p_manager,
                free_disks_clone,
                free_printers_clone,
            )
            .run();
        }));
    }

    // waiting for all users to finish
    for handle in handles {
        handle.join().unwrap()
    }
}

fn request(lock: &Mutex<Vec<bool>>, cvar: &Condvar) -> u32 {
    let mut free_items = lock.lock().unwrap();
    loop {
        for i in 0..free_items.len() {
            if free_items[i] {
                free_items[i] = false;
                return i as u32;
            }
        }
        free_items = cvar.wait(free_items).unwrap(); // unwrap used to get value of object in the case it is Ok (panics else)
    }
}

fn release(lock: &Mutex<Vec<bool>>, cvar: &Condvar, index: u32) -> () {
    let mut free_items = lock.lock().unwrap();
    free_items[index as usize] = true;
    cvar.notify_one();
}

struct UserThread {
    id: u32,
    d_manager: Arc<Mutex<DiskManager>>,
    p_manager: Arc<Mutex<PrinterManager>>,
    free_disks: Arc<(Mutex<Vec<bool>>, Condvar)>,
    free_printers: Arc<(Mutex<Vec<bool>>, Condvar)>,
}

impl UserThread {
    fn new(
        id: u32,
        d_manager: Arc<Mutex<DiskManager>>,
        p_manager: Arc<Mutex<PrinterManager>>,
        free_disks: Arc<(Mutex<Vec<bool>>, Condvar)>,
        free_printers: Arc<(Mutex<Vec<bool>>, Condvar)>,
    ) -> Self {
        UserThread {
            id,
            d_manager,
            p_manager,
            free_disks,
            free_printers,
        }
    }

    fn run(&self) -> () {
        let filename = format!("./src/USER{}", self.id);

        let reader = UserThread::get_file(&filename);

        let mut f_name: String = String::new(); // name of file
        let mut f_length: u32 = 0; // length of file
        let mut disk_num: u32 = 0; // which disk we are using to store
        let mut disk: Option<Disk> = None;
        for line in reader.lines() {
            let line = line.unwrap();
            let parts: Vec<&str> = line.split_whitespace().collect();

            match parts[0] {
                ".save" => {
                    let (lock, cvar) = &*self.free_disks;
                    let disk_id = request(&lock, &cvar); // get next available disk
                    disk_num = disk_id;
                    let mut d_manager = self.d_manager.lock().unwrap(); // lock the disk manager to current user
                    f_name = String::from(parts[1]);

                    disk = Some(d_manager.create_file(&f_name, disk_id)); // create file in disk manager on disk
                }
                ".end" => {
                    let mut d_manager = self.d_manager.lock().unwrap(); // lock disk manager to update info about file
                    let file = d_manager.directory.lookup_mut(&f_name);
                    file.file_length = f_length; // update file length
                    f_length = 0; // reset counter
                    if let Some(disk) = disk.take() {
                        d_manager.disks[disk_num as usize] = disk;
                    }
                    
                    let (lock, cvar) = &*self.free_disks;
                    release(&lock, &cvar, disk_num); // free disk to other users
                }
                ".print" => {
                    let (lock, cvar) = &*self.free_printers;
                    let printer_id = request(&lock, &cvar); // get available printer

                    let (file_length, file_starting_sector, disk_clone, printer) = {
                        let d_manager = self.d_manager.lock().unwrap();

                        let file = d_manager.directory.lookup(&String::from(parts[1])); // get the file info
                        let disk_c = d_manager.disks[file.disk_number as usize].clone();
                        // get the disk the file is on
                        let p_manager = self.p_manager.lock().unwrap(); // lock the printer manager
                        let printer = p_manager.printers[printer_id as usize];

                        (file.file_length, file.starting_sector, disk_c, printer)
                    }; // block this code so that d_manager & p_manager fall out of scope and unlock for other threads

                    print_job(printer, disk_clone, file_length, file_starting_sector); // print_file

                    release(&lock, &cvar, printer_id); // release printer
                }
                _ => {
                    let starting_sector = {
                        let d_manager = self.d_manager.lock().unwrap();
                        let file = d_manager.directory.lookup(&f_name);
                        file.starting_sector
                    };
                    if let Some(disk) = &mut disk {
                        disk.write(&line, starting_sector + f_length);
                        f_length += 1;
                    }
                }
            }
        }
    }

    fn get_file(filename: &String) -> BufReader<File> {
        BufReader::new(File::open(filename).expect("File does not exist"))
    }
}

#[derive(Debug)]
struct DiskManager {
    directory: DirectoryManager,
    disks: Vec<Disk>,
}

impl DiskManager {
    fn new(num_of_disks: u32) -> Self {
        let mut d: Vec<Disk> = Vec::new();
        for _ in 0..num_of_disks {
            d.push(Disk::new());
        }
        DiskManager {
            directory: DirectoryManager::new(),
            disks: d,
        }
    }

    fn create_file(&mut self, f_name: &String, disk_num: u32) -> Disk {
        let disk = &mut self.disks[disk_num as usize];

        self.directory
            .enter(f_name, FileInfo::new(disk_num, disk.next_available_sector));
        disk.next_available_sector += 5;
        self.disks[disk_num as usize].clone()
    }
}

struct PrinterManager {
    printers: Vec<Printer>,
}

impl PrinterManager {
    fn new(num_of_printers: u32) -> Self {
        let mut p: Vec<Printer> = Vec::new();
        for i in 0..num_of_printers {
            p.push(Printer::new(i));
        }
        PrinterManager { printers: p }
    }
}

#[derive(Debug)]
struct DirectoryManager {
    directory: HashMap<String, FileInfo>,
}

impl DirectoryManager {
    fn new() -> Self {
        DirectoryManager {
            directory: HashMap::new(),
        }
    }

    fn enter(&mut self, file_name: &String, file: FileInfo) -> () {
        self.directory.insert(String::from(file_name), file);
    }

    fn lookup(&self, file_name: &String) -> &FileInfo {
        self.directory.get(file_name).expect("Key does not exist")
    }

    fn lookup_mut(&mut self, file_name: &String) -> &mut FileInfo {
        self.directory
            .get_mut(file_name)
            .expect("Key does not exist")
    }
}

fn print_job(printer: Printer, disk: Disk, file_length: u32, starting_sector: u32) -> () {
    let handle = thread::spawn(move || {
        for i in 0..file_length {
            let data = disk.read(starting_sector + i);
            printer.print(data)
        }
    });

    handle.join().unwrap();
}

#[derive(Debug)]
struct FileInfo {
    disk_number: u32,
    starting_sector: u32,
    file_length: u32,
}

impl FileInfo {
    fn new(disk_number: u32, starting_sector: u32) -> Self {
        FileInfo {
            disk_number,
            starting_sector,
            file_length: 0,
        }
    }
}

#[derive(Debug, Clone)]
struct Disk {
    sectors: Vec<String>,
    next_available_sector: u32,
}

impl Disk {
    const NUM_SECTORS: u32 = 2000;

    fn new() -> Self {
        Disk {
            sectors: vec![String::new(); Disk::NUM_SECTORS as usize],
            next_available_sector: 0,
        }
    }
    fn write(&mut self, data: &String, sector: u32) -> () {
        self.sectors[sector as usize] = String::from(data);
        thread::sleep(time::Duration::from_millis(5));
    }

    fn read(&self, sector: u32) -> &String {
        thread::sleep(time::Duration::from_millis(5));
        &self.sectors[sector as usize]
    }
}
#[derive(Copy, Clone)]
struct Printer {
    id: u32,
}

impl Printer {
    fn new(id: u32) -> Self {
        Printer { id }
    }

    fn print(&self, data: &String) {
        let f_name = format!("./src/PRINTER{}", self.id);
        let mut f = OpenOptions::new()
            .create(true)
            .append(true)
            .open(f_name)
            .unwrap();
        let content = data.as_str();
        writeln!(f, "{content}").unwrap();
        thread::sleep(time::Duration::from_millis(10));
    }
}
