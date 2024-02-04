#include <iostream>
#include <string>
using namespace std;

typedef void (*void_method_type)(void*);
typedef double (*double_method_type)(void*);

typedef union
{
    double_method_type double_method;
    void_method_type void_method;
} VirtualTableEntry;

typedef VirtualTableEntry* VTableType;

#define PI 3.14159

// Shape

#define PRINT_INDEX 0
#define DRAW_INDEX 1
#define AREA_INDEX 2

struct Shape
{
    VTableType vpointer;
    string name;
};

VirtualTableEntry Shape_VTable[] = {};

Shape* Shape_Constructor(Shape* _this, string name)
{
    _this->vpointer = Shape_VTable;
    _this->name = name;
    return _this;
}

// Circle

struct Circle
{
    VTableType vpointer;
    string name;
    int radius;
};

void Circle_print(Circle* _this)
{
    cout << _this->name << "(" << _this->radius << ") : " << _this->vpointer[AREA_INDEX].double_method(_this) << endl;
}

void Circle_draw(Circle* _this)
{
    cout << " **** " << endl;
    cout << "**  **" << endl;
    cout << "**  **" << endl;
    cout << " **** " << endl;
}

double Circle_area(Circle* _this)
{
    return PI * _this->radius * _this->radius;
}

VirtualTableEntry Circle_VTable[] =
{
    {.void_method = (void_method_type)Circle_print},
    {.void_method = (void_method_type)Circle_draw},
    {.double_method = (double_method_type)Circle_area} };

Circle* Circle_Constructor(Circle* _this, string name, int radius)
{
    Shape_Constructor((Shape*)_this, name);
    _this->vpointer = Circle_VTable;
    _this->radius = radius;
    return _this;
}

// Triangle
struct Triangle
{
    VTableType vpointer;
    string name;
    int base, height;
};

void Triangle_print(Triangle* _this)
{
    cout << _this->name << "(" << _this->base << "," << _this->height << ") : " << _this->vpointer[AREA_INDEX].double_method(_this) << endl;
}

void Triangle_draw(Triangle* _this)
{
    cout << "   *   " << endl;
    cout << "  * *  " << endl;
    cout << " *   * " << endl;
    cout << "*******" << endl;
}

double Triangle_area(Triangle* _this)
{
    return 0.5 * _this->base * _this->height;
}

VirtualTableEntry Triangle_VTable[] =
{
    {.void_method = (void_method_type)Triangle_print},
    {.void_method = (void_method_type)Triangle_draw},
    {.double_method = (double_method_type)Triangle_area}
};

Triangle* Triangle_Constructor(Triangle* _this, string name, int base, int height)
{
    Shape_Constructor((Shape*)_this, name);
    _this->vpointer = Triangle_VTable;
    _this->base = base;
    _this->height = height;
    return _this;
}

// Square
struct Square {
    VTableType vpointer;
    string name;
    int height;
};

void Square_print(Square* _this)
{
    cout << _this->name << "(" << _this->height << ") : " << _this->vpointer[AREA_INDEX].double_method(_this) << endl;
}

void Square_draw(Square* _this)
{
    cout << "******" << endl;
    cout << "*    *" << endl;
    cout << "*    *" << endl;
    cout << "*    *" << endl;
    cout << "*    *" << endl;
    cout << "*    *" << endl;
    cout << "******" << endl;
}

double Square_area(Square* _this)
{
    return _this->height * _this->height;
}

VirtualTableEntry Square_VTable[] =
{
    {.void_method = (void_method_type)Square_print},
    {.void_method = (void_method_type)Square_draw},
    {.double_method = (double_method_type)Square_area}
};

Square* Square_Constructor(Square* _this, string name, int height)
{
    Shape_Constructor((Shape*)_this, name);
    _this->vpointer = Square_VTable;
    _this->height = height;
    return _this;
}

/// Rectangle
struct Rectangle {
    VTableType vpointer;
    string name;
    int height, width;
};

void Rectangle_print(Rectangle* _this)
{
    cout << _this->name << "(" << _this->height << "," << _this->width << ") : " << _this->vpointer[AREA_INDEX].double_method(_this) << endl;
}

void Rectangle_draw(Rectangle* _this)
{
    cout << "******" << endl;
    cout << "*    *" << endl;
    cout << "*    *" << endl;
    cout << "******" << endl;
}

double Rectangle_area(Rectangle* _this)
{
    return _this->width * _this->height;
}

VirtualTableEntry Rectangle_VTable[] =
{
    {.void_method = (void_method_type)Rectangle_print},
    {.void_method = (void_method_type)Rectangle_draw},
    {.double_method = (double_method_type)Rectangle_area}
};

Rectangle* Rectangle_Constructor(Rectangle* _this, string name, int height, int width)
{
    Square_Constructor((Square*)_this, name, height);
    _this->vpointer = Rectangle_VTable;
    _this->width = width;
    return _this;
}

// Picture Functions
void printAll(Shape** arr, int n)
{
    for (int i = 0; i < n; ++i)
        arr[i]->vpointer[PRINT_INDEX].void_method(arr[i]);
}

void drawAll(Shape** arr, int n)
{
    for (int i = 0; i < n; ++i)
        arr[i]->vpointer[DRAW_INDEX].void_method(arr[i]);
}

double totalArea(Shape** arr, int n)
{
    double area = 0;
    for (int i = 0; i < n; ++i)
        area += arr[i]->vpointer[AREA_INDEX].double_method(arr[i]);
    return area;
}

int main(int argc, char const* argv[])
{
    if (argc - 1 != 2) {
        cout << "Expecting two agruments" << endl;
        return -1;
    }
    int arg1 = atoi(argv[1]);
    int arg2 = atoi(argv[2]);
    Shape* arr[] = {
        (Shape*)(Triangle_Constructor((Triangle*)malloc(sizeof(Triangle)), "FirstTriangle", arg1, arg2)),
        (Shape*)(Triangle_Constructor((Triangle*)malloc(sizeof(Triangle)), "SecondTriangle", arg1 - 1, arg2 - 1)),
        (Shape*)(Circle_Constructor((Circle*)malloc(sizeof(Circle)), "FirstCircle", arg1)),
        (Shape*)(Circle_Constructor((Circle*)malloc(sizeof(Circle)), "SecondCircle", arg1 - 1)),
        (Shape*)(Square_Constructor((Square*)malloc(sizeof(Square)), "FirstSquare", arg1)),
        (Shape*)(Square_Constructor((Square*)malloc(sizeof(Square)), "SecondSquare", arg1 - 1)),
        (Shape*)(Rectangle_Constructor((Rectangle*)malloc(sizeof(Rectangle)), "FirstRectangle", arg1, arg2)),
        (Shape*)(Rectangle_Constructor((Rectangle*)malloc(sizeof(Rectangle)), "SecondRectangle", arg1 - 1, arg2 - 1)),
    };

    int arr_length = 8;
    printAll(arr, arr_length);
    drawAll(arr, arr_length);
    cout << "Total : "  << totalArea(arr, arr_length) << endl;
}
