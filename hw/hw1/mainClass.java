public class mainClass {
    public static void main(String[] args){
        if(args.length != 2){
            System.out.println("Exepcting two arguments");
            System.exit(-1);
        }
        Picture p = new Picture();
        int arg1 = Integer.valueOf(args[0]);
        int arg2 = Integer.valueOf(args[1]);
        p.add(new Triangle("FirstTriangle", arg1, arg2));
        p.add(new Triangle("SecondTriangle", arg1-1, arg2-1));
        p.add(new Circle("FirstCircle", arg1));
        p.add(new Circle("SecondCircle", arg1-1));
        p.add(new Square("FirstSquare", arg1));
        p.add(new Square("SecondSquare", arg1-1));
        p.add(new Rectangle("FirstRectangle", arg1, arg2));
        p.add(new Rectangle("SecondRectangle", arg1-1, arg2-1));
        p.printAll();
        p.drawAll();
        System.out.println("Total : " + p.totalArea());
    }
}

abstract class Shape {
    String name;
    public Shape(String name){
        this.name = name;
    }
    abstract void print();
    abstract void draw();
    abstract double area();
}

class Circle extends Shape {
    int radius;
    public Circle(String name, int radius){
        super(name);
        this.radius = radius;
    }

    void print(){
        System.out.println(name + "(" + radius + ") : " + this.area());
    }

    void draw(){
        System.out.println(" **** ");
        System.out.println("**  **");
        System.out.println("**  **");
        System.out.println(" **** ");
    }

    double area(){
        return Math.PI * radius * radius;
    }
}

class Triangle extends Shape {
    int base, height;
    public Triangle(String name, int base, int height){
        super(name);
        this.base = base;
        this.height = height;
    }

    void print(){
        System.out.println(name + "(" + base + ", " + height + ") : " + this.area());
    }

    void draw(){
        System.out.println("   *   ");
        System.out.println("  * *  ");
        System.out.println(" *   * ");
        System.out.println("*******");
    }

    double area(){
        return 0.5 * base * height;
    }
}

class Square extends Shape {
    int height;
    public Square(String name, int height){
        super(name);
        this.height = height;
    }

    void print(){
        System.out.println(name + "(" + height + ") : " + this.area());
    }

    void draw(){
        System.out.println("******");
        System.out.println("*    *");
        System.out.println("*    *");
        System.out.println("*    *");
        System.out.println("*    *");
        System.out.println("*    *");
        System.out.println("******");
    }

    double area(){
        return height * height;
    }
}

class Rectangle extends Square {
    int width;
    public Rectangle(String name, int height, int width){
        super(name, height);
        this.width = width;
    }

    void print(){
        System.out.println(name + "(" + height + ", " + width + ") : " + this.area());
    }

    void draw(){
        System.out.println("******");
        System.out.println("*    *");
        System.out.println("*    *");
        System.out.println("******");
    }

    double area(){
        return width * height;
    }
}

class ListNode {
    Shape s;
    ListNode next;
    public ListNode(Shape s, ListNode next){
        this.s = s;
        this.next = next;
    }
}

class Picture {
    ListNode head;
    public Picture(){}
    
    void add(Shape s){
        ListNode temp = new ListNode(s, head);
        head = temp;
    }
    
    void printAll(){
        ListNode temp = head;
        while(temp != null){
            temp.s.print();
            temp = temp.next;
        }
    }

    void drawAll(){
        ListNode temp = head;
        while(temp != null){
            temp.s.draw();
            temp = temp.next;
        }
    }

    double totalArea(){
        double total = 0;
        ListNode temp = head;
        while(temp != null){
            total += temp.s.area();
            temp = temp.next;
        }
        return total;
    }
}

