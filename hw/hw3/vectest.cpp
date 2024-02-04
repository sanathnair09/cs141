#include "vector.h"

int main() {
    // init
    Vector<int> v(10);
    cout << (v.size() == 10) << endl;
    cout << v << endl;

    // init list
    Vector<int> v2{ 1, 2, 3 };
    cout << (v2.size() == 3) << endl;
    cout << v2 << endl;

    //deep copy
    Vector<int> v3{ v2 };
    cout << (v3.size() == 3) << endl;
    cout << v3 << endl;

    //assignment
    v3[0] = -1;
    cout << v3 << endl;

    //const operator[]
    int first = v3[0];
    cout << first << endl;

    //dot product
    Vector<int> v4{ 1,2 };
    Vector<int> v5{ 3,4,5 };
    cout << v4 * v5 << endl;

    //vector addition
    Vector<int> v6{ 1,2,3 };
    Vector<int> v7{ 4,5,6,7 };
    cout << v6 + v7 << endl;

    //copy
    Vector<int> v8{ 1,2,3 };
    Vector<int> v9{ 4,5,6 };
    cout << v8 << endl;
    cout << v9 << endl;
    v8 = v9;
    cout << v8 << endl;
    cout << v9 << endl;

    // equivalence
    Vector<int> v10{ 1,2,3 };
    Vector<int> v11{ 4,5,6 };
    cout << (v10 == v11) << endl;
    cout << (v10 == v10) << endl;
    cout << (v10 != v11) << endl;
    cout << (v10 != v10) << endl;

    // scalar mult
    cout << (20 * v10) << endl;

    // scalar add
    cout << (20 + v10) << endl;

}