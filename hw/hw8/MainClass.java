import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;

import java.lang.Thread;

import java.util.Hashtable;

class Disk // extends Thread
{
    static final int NUM_SECTORS = 2048;
    static final int DISK_DELAY = 80; // 80 for Gradescope
    StringBuffer sectors[] = new StringBuffer[NUM_SECTORS];
    int nextAvailableSector = 0;

    Disk() {
    }

    void write(int sector, StringBuffer data) // call sleep
    {
        try {
            sectors[sector] = data;
            nextAvailableSector = sector + 1;
            Thread.sleep(DISK_DELAY);
        } catch (InterruptedException e) {
            System.out.println("InterruptedException: " + e);
        }
    }

    StringBuffer read(int sector) // call sleep
    {
        try {
            Thread.sleep(DISK_DELAY);
            return sectors[sector];
        } catch (InterruptedException e) {
            System.out.println("InterruptedException: " + e);
        }
        return null;
    }
}

class Printer // extends Thread
{
    static final int PRINT_DELAY = 275; // 275 for Gradescope
    int id;

    Printer(int id) {
        this.id = id;
    }

    void print(StringBuffer data) // call sleep
    {
        try {
            FileWriter fw = new FileWriter("./PRINTER" + this.id, true);
            fw.write(data.toString());
            fw.write("\n");
            fw.close();

            Thread.sleep(PRINT_DELAY);
        } catch (Exception e) {
            System.out.println(e);
        }
    }
}

class PrintJobThread extends Thread {
    Printer printer;
    Disk disk;
    FileInfo file;

    PrintJobThread(Printer printer, Disk disk, FileInfo file) {
        this.printer = printer;
        this.disk = disk;
        this.file = file;
    }

    public void run() {
        StringBuffer data = new StringBuffer();
        for (int i = 0; i < file.fileLength; i++) {
            data = disk.read(file.startingSector + i);
            printer.print(data);
        }
    }
}

class FileInfo {
    // used in DirectoryManager to hold meta info about a file
    // used in PrintJobThread to locate the file contents
    int diskNumber;
    int startingSector;
    int fileLength;

    FileInfo(int diskNumber, int startingSector) {
        this.diskNumber = diskNumber;
        this.startingSector = startingSector;
        this.fileLength = -1;
    }
}

class DirectoryManager {
    // <key, value> => <filename, fileinfo>
    private Hashtable<String, FileInfo> directory = new Hashtable<String, FileInfo>();

    DirectoryManager() {
    }

    void enter(StringBuffer fileName, FileInfo file) {
        directory.put(fileName.toString(), file);
    }

    FileInfo lookup(StringBuffer fileName) {
        return directory.getOrDefault(fileName.toString(), null);
    }
}

class ResourceManager {
    boolean isFree[];

    ResourceManager(int numberOfItems) {
        isFree = new boolean[numberOfItems];
        for (int i = 0; i < isFree.length; ++i)
            isFree[i] = true;
    }

    synchronized int request() throws InterruptedException {
        while (true) {
            for (int i = 0; i < isFree.length; ++i)
                if (isFree[i]) {
                    isFree[i] = false;
                    return i;
                }
            this.wait(); // block until someone releases Resource
        }
    }

    synchronized void release(int index) {
        isFree[index] = true;
        this.notify(); // let a blocked thread run
    }
}

class DiskManager extends ResourceManager {
    DirectoryManager manager = new DirectoryManager();
    Disk[] disks;

    DiskManager(int numberOfDisks) {
        super(numberOfDisks);

        disks = new Disk[numberOfDisks];
        for (int i = 0; i < numberOfDisks; i++) {
            disks[i] = new Disk();
        }
    }

    void createFile(StringBuffer filename) {
        try {
            int diskNumber = request();
            Disk disk = disks[diskNumber];
            
            manager.enter(filename, new FileInfo(diskNumber, disk.nextAvailableSector));

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    void writeToDisk(StringBuffer filename, StringBuffer content, int offset) {
        FileInfo file = manager.lookup(filename);
        Disk disk = disks[file.diskNumber];

        disk.write(file.startingSector + offset, content);
    }
}

class PrinterManager extends ResourceManager {
    Printer[] printers;

    PrinterManager(int numberOfPrinters) {
        super(numberOfPrinters);
        printers = new Printer[numberOfPrinters];
        for (int i = 0; i < numberOfPrinters; i++) {
            printers[i] = new Printer(i);
        }
    }

    void print(Disk disk, FileInfo file) {
        try {
            int printerNumber = request();
            Printer printer = printers[printerNumber];

            PrintJobThread pJobThread = new PrintJobThread(printer, disk, file);
            pJobThread.start();

            release(printerNumber);
        } catch (Exception e) {
            System.out.println(e);
        }

    }
}

class UserThread extends Thread {
    int id;
    DiskManager dManager;
    PrinterManager pManager;

    // my commands come from an input file with name USERi where i is my user id
    UserThread(int id, DiskManager dManager, PrinterManager pManager) {
        this.id = id;
        this.dManager = dManager;
        this.pManager = pManager;
    }

    public void run() {
        String fileName = "./USER" + this.id;
        try {
            BufferedReader reader = new BufferedReader(new FileReader(fileName));

            String line = reader.readLine();
            
            StringBuffer fName = new StringBuffer();
            int offset = 0;
            while (line != null) {
                String[] parts = line.split(" ");
                switch (parts[0]) {
                    case ".save":
                        fName = new StringBuffer(parts[1]);
                        dManager.createFile(fName);
                        break;
                    case ".end":
                        FileInfo f = dManager.manager.lookup(fName);
                        f.fileLength = offset;
                        dManager.release(f.diskNumber); // release here to make sure that overwrites don't happen
                        offset = 0;
                        break;
                    case ".print":
                        FileInfo file = dManager.manager.lookup(new StringBuffer(parts[1]));
                        Disk disk = dManager.disks[file.diskNumber];
                        pManager.print(disk, file);
                        break;
                    default: // line to save
                        dManager.writeToDisk(fName, new StringBuffer(line), offset++);
                        break;
                }

                line = reader.readLine();
            }
            reader.close();
        } catch (Exception e) {
            System.out.println(e);
        }
    }
}

public class MainClass {
    public static void main(String args[]) {
        // -#ofUsers -#ofDisks -#ofPrinters
        if (args.length != 3) {
            System.out.println("Incorrect number of arguments");
            return;
        }

        int numOfUsers = Integer.parseInt(args[0].substring(1));
        int numofDisks = Integer.parseInt(args[1].substring(1));
        int numOfPrinters = Integer.parseInt(args[2].substring(1));

        DiskManager dManager = new DiskManager(numofDisks);
        PrinterManager pManager = new PrinterManager(numOfPrinters);

        for (int i = 0; i < numOfUsers; i++)
            new UserThread(i, dManager, pManager).start();
    }
}