#include <iostream>

void f(int x){
    int x = 1;
    for (int x = 0; x < 10; ++x)
    {
        int x = 3;
        std::cout << x;
    }
}

int main(int argc, char const *argv[])
{
    int x = 0;
    f(x);
    return 0;
}
