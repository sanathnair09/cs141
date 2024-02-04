#ifndef VECTOR_H
#define VECTOR_H
#include <iostream>
using namespace std;
/* Commented by Safeeullah Saifuddin, Fall 2022 */
/** ADVISED ORDER OF IMPLEMENTATION
 * 1. Constructors
 * 2. Inserter (<<) -> allows you to print & see what is in the vector throughout development
 * 3. Write test cases that use some of the constructors and print those vectors out
 * 4. Write a test case for a function
 * 5. Implement the function and test until you are confident on its correctness
 * 6. Repeat from 4 until all methods are implemented and tested
 * 7. Implement the destructor last; if there are still errors,
      then you know it is due to memory management
*/
template <typename T> // We will only be testing int and double
class Vector {
private:

    /**
     * size_t sz   size of the vector i.e the amount of elements in the vector
    */
    size_t sz;

    /**
     * T* buf  pointer to the base (first element) of a dynamically allocated array
     *    Be careful to manage its memory wisely (calling del[] when necessary)
    */
    T* buf;
public:
    /**
     * Constructs a vector of size sz
     *
     * ex: Vector v(10); -> constructs a 10 elem Vector
     * @param sz size of vector
    */
    Vector(size_t sz) : sz(sz) {
        buf = new T[sz];
    }

    /**
     * Constructs a vector from a list of elements
     *
     * ex: Vector v1{1, 2, 3}; -> creates a vector with values 1, 2, 3 and size 3
     * @param L a list of values to initialize our vector
     *   - L.size() gives the list's size
     *   - You can iterate through it using an iterator
    */
    Vector(initializer_list<T> L) {
        buf = new T[L.size()];
        size_t i = 0;
        for (const auto& item : L)
            buf[i++] = item;
        sz = L.size();
    }

    /**
       * Destructs the object at the end of the object's lifecycle
       *  - Automatically called
       * Deallocate the array here.
       * Some versions of valgrind report 72704 bytes in one still-reachable block.
       * You can ignore that.
      */
    ~Vector() {
        delete[] buf;
    }
    /**
     * Copy constructor; makes a new Vector by deep copying the vector passed to it
     * ex: Vector v2{v1};
    */
    Vector(const Vector& v) {
        buf = new T[v.sz];
        for (size_t i = 0; i < v.sz; i++)
            buf[i] = v[i];
        sz = v.sz;
    }

    /**
     * Returns the size of the vector
     * ex: Vector v1(10); v1.size(); -> will return 10
     * @return size of vector
    */
    size_t size() const {
        return sz;
    }
    /**
    * Overloads the [] operator and returns a reference to the value at index i in the
    * dynamically allocated array. This would be used to change the value at that index.
    * Throws an error when accessing index out of bounds
    * ex: v1[2] = 3;
    * @param i index of elem in buf that will be accessed
    */
    T& operator [] (const int i) {
        return (size_t)i < sz ? buf[i] : throw out_of_range("Index out of range");
    }
    /**
    * Overloads the [] operator and returns the value of the elem at index i in the
    * dynamically allocated array. This would be used to access the value at that index
    * without modifying it.
    * Throws an error when accessing index out of bounds
    * ex: T elemAtInd3 = v1[3];
    * @param i index of elem in buf that will be accessed
    */
    T operator [] (const int i) const {
        return (size_t)i < sz ? buf[i] : throw out_of_range("Index out of range");
    }

    /**
     * Dot products the current vector with the passed vector.
     * The dot product of two vectors is the sum of the products
     * of the corresponding entries of two sequences of numbers.
     *
     * ex: T x = V1 * V2;
     * dot product: [1, 2] * [3, 4, 5] = 1 * 3 + 2 * 4 + 0 = 11
     * Assume an empty Vector will cause the product to be 0.
     * @param v Vector on the right to dot product with
     * @return a scalar value with type T (not a vector!) that is the dot product of the
     *    two vectors
    */
    T operator * (const Vector& v) const {
        T sum = 0;
        size_t min_size = sz < v.sz ? sz : v.sz;
        for (size_t i = 0; i < min_size; ++i)
            sum += buf[i] * v[i];

        return sum;
    }

    /**
     * Adds the current vector with the passed vector and returns a new vector.
     * ex: V3 = V1 + V2;
     * addition: [1, 2, 3] + [4, 5, 6, 7] = [5, 7, 9, 7]
     * @param v Vector on the right to perform addition with
     * @return new vector where index i is the result of this[i] + v[i]
    */
    Vector operator + (const Vector& v) const {
        size_t max_size = sz > v.sz ? sz : v.sz;
        size_t min_size = sz < v.sz ? sz : v.sz;
        Vector result(max_size);

        for (size_t i = 0; i < min_size; ++i)
            result[i] = buf[i] + v[i];

        if (sz < v.sz) {
            while (min_size < max_size)
            {
                result[min_size] = v[min_size];
                ++min_size;
            }
        }
        else {
            while (min_size < max_size)
            {
                result[min_size] = buf[min_size];
                ++min_size;
            }

        }
        return result;
    }

    /**
     * Destructs the current vector and deep copies the passed vector
     * ex: V1 = V2;
     * V1 could be an already existing vector, be sure to clean it up before the deep copy
     * @param v Vector on the right to deep copy
     * @return reference to the current object
    */
    const Vector& operator = (const Vector& v) {
        delete[] buf;

        buf = new T[v.sz];
        for (int i = 0; i < v.sz; i++)
            buf[i] = v[i];
        
        sz = v.sz;

        return *this;
    }

    /**
     * Determines whether the current vector is equivalent to the passed vector
     * ex: bool isV1AndV2Same = V1 == V2;
     * @param v Vector on the right to compare current with
     * @return true if both vectors are deeply equivalent (elem by elem comparison)
     * and false otherwise
    */
    bool operator == (const Vector& v) const {
        if (sz != v.sz) return false;
        for (size_t i = 0; i < sz; i++)
            if (buf[i] != v[i]) return false;
        return true;
    }

    /**
     * Determines whether the current vector is not equivalent to the passed vector
     * ex: bool isV1AndV2Different = V1 != V2;
     * @param v Vector on the right to compare current with
     * @return false if both vectors are deeply equivalent (elem by elem comparison)
     * and true otherwise
    */
    bool operator != (const Vector& v) const {
        return !(*this == v);
    }

    /**
     * Multiplies each element in current vector with the passed integer and returns a new vector.
     * ex: V1 = 20 * V2; it is important that 20 is on the left!
     * 20 * [1, 2, 3] = [20, 40, 60]
     * @param scale integer to multiple each element of vector v
     * @param v Vector on the right to perform multiplication on
     * @return new vector where index i is the result of v[i] * scale
    */
    inline friend Vector operator * (const int scale, const Vector& v) {
        Vector result(v.sz);

        for (size_t i = 0; i < v.sz; ++i)
            result[i] = scale * v[i];

        return result;
    }

    /**
     * Adds each element in the current vector with the passed integer and returns a new vector.
     * ex: V1 = 20 + V2; it is important that 20 is on the left!
     * 20 + [1, 2, 3] = [21, 22, 23]
     * @param adder integer to add to each element of vector v
     * @param v Vector on the right to perform addition on
     * @return new vector where index i is the result of v[i] + adder
    */
    inline friend Vector operator + (const int adder, const Vector& v) {
        Vector result(v.sz);

        for (size_t i = 0; i < v.sz; ++i)
            result[i] = adder + v[i];

        return result;
    }

    /**
     * Allows the << operator to correctly print out the vector.
     * ex: cout << V2; -> (v[0], v[1], v[2], ... v[sz-1])
     * @param o ostream to print the elems of the array, usage is o << thingToPrint;
     * @param v vector that will be printed out
     * @return the ostream passed in
    */
    inline friend ostream& operator << (ostream& o, const Vector& v) {
        o << "(";
        for (size_t i = 0; i < v.sz - 1; ++i)
            o << v[i] << ", ";
        o << v[v.sz - 1] << ")" << endl;
        return o;
    }

};
#endif