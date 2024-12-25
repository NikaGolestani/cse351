#ifndef ITEM_TYPE_H
#define ITEM_TYPE_H

struct item {
    bool is_constant;
    int value;
};

typedef struct item item;  // Ensure typedef is correct

#endif // ITEM_TYPE_H