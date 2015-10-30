import std.stdio;
import std.exception;
import std.conv;

class DataTrie_AA(T) {

    struct Item(T) {
        bool leaf;
        T value;
        Item[dchar] children;

        this(bool leaf) {
            this.leaf = leaf;
        }
    };

    Item!T root = Item!T(false);

    this() {
    }

    void add(string str, T value) {
        add(&root, str, 0, value);
    }

    void remove(string str) {
        remove(&root, str, 0);
    }

    bool check(string str) {
        return check(&root, str, 0);
    }

    uint length() {
        return length(&root);
    }

    T get(string str) {
        return get(&root, str, 0);
    }

    void walker(void delegate(string name, T value) func) {
        walker(&root, "", func);
    }

    private {
        void add(Item!T* item, string str, uint index, T value) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                item.leaf = true;
                item.value = value;
            } else {
                dchar character = str[index];
                if (character in item.children) {
                    add(&item.children[character], str, index+1, value);
                    return;
                }
                // no entry found; create new one
                item.children[character] = Item!T(isLastCharacter);
                add(&item.children[character], str, index+1, value);
            }
        }

        bool remove(Item!T* item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                item.leaf = false;
                item.value = T.init;
                return item.children.length == 0;
            } else {
                dchar character = str[index];
                foreach (key, ref child; item.children) {
                    if (key == character) {
                        bool result = remove(&child, str, index+1);
                        if (result) {
                            // delete child node
                            item.children.remove(key);
                        }
                        return item.children.length == 0;
                    }
                }
                return false;
            }
        }

        bool check(Item!T* item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                return item.leaf;
            } else {
                dchar character = str[index];
                if (character in item.children) {
                    return check(&item.children[character], str, index+1);
                }
                return false;
            }
        }

        T get(Item!T* item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                return item.value;
            } else {
                dchar character = str[index];
                if (character in item.children) {
                    return get(&item.children[character], str, index+1);
                }
                return T.init;
            }
        }

        uint length(Item!T* item) {
            uint result = 0;
            if (item.leaf) {
                result += 1;
            }
            foreach (ref child; item.children) {
                result += length(&child);
            }
            return result;
        }
    
        void walker(Item!T* item, string partialValue, void delegate(string value, T value) func) {
            if (item.leaf) {
                func(partialValue, item.value);
            }
            foreach (key, ref child; item.children) {
                walker(&child, partialValue ~ to!string(key), func);
            }
        }
    }
};

unittest {

    auto trie = new DataTrie_AA!int();
    assert(trie.length() == 0);
    trie.add("abcd", 1);

    assert(trie.length() == 1);
    assert(!trie.check("a"));
    
    trie.add("abcd", 1);
    assert(trie.check("abcd"));
    assert(trie.get("abcd") == 1);
    assert(!trie.check("a"));

    uint numberOfEntries = 0;
    bool correctEntry = true;
    trie.walker(delegate (string name, int value) { 
        numberOfEntries += 1; 
        if (name != "abcd") {
            correctEntry = false;
        }
        if (value != 1) {
            correctEntry = false;
        }
    });
    assert(numberOfEntries == 1);
    assert(correctEntry);

    trie.add("a", 2);
    assert(trie.check("a"));
    assert(trie.length() == 2);
    
    trie.add("a", 3);
    trie.add("a", 4);
    trie.add("a", 5);
    trie.add("a", 6);
    trie.add("a", 7);
    assert(trie.check("a"));
    assert(trie.check("a"));

    trie.add("abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz", 7);
    assert(trie.check("abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz abcdefghijklmnopqrvwxyz"));
    

    assert(!trie.check(""));
    trie.add("", 8);
    assert(trie.check(""));
    assert(trie.get("") == 8);

    import std.file;
    import std.string;

    if (exists("/usr/share/dict/words")) {
        File file = File("/usr/share/dict/words", "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
                trie.add(line, to!uint(lines.length));
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
    }

    if (exists("/usr/share/dict/cracklib-small")) {
        File file = File("/usr/share/dict/cracklib-small", "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
                trie.add(line, to!uint(lines.length));
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
    }

    assert(!trie.check("Daniel Kullmann"));
    assert(trie.get("Daniel Kullmann") == uint.init);

    uint count = 0;
    trie.walker(delegate (string name, int value) { count += 1; });
    assert(count == trie.length());

    count = trie.length();
    trie.add("todelete", 2);
    assert(trie.check("todelete"));
    assert(count+1 == trie.length());
    trie.remove("todelete");
    assert(!trie.check("todelete"));
    assert(count == trie.length());
}

