#include <iostream>

using namespace std;

class Animal {
public:
	Animal() {
		cout << "Animal Created" << endl;
	}
	virtual void sound() {
		cout << "SOUND" << endl;
	}
};

class Bird : public Animal {
public:
	Bird() : Animal() {
		cout << "This animal is a bird." << endl;
	}

	void sound() {
		cout << "Chirp" << endl;
	}
};

int main() {
	Animal a;
	Bird b;

	Animal *ptr= &a;
    ptr->sound();
    ptr = &b;
    ptr->sound();
	
	return 0;
}
