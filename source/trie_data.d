import std.stdio;
import std.exception;
import std.conv;

struct Item(T) {
    dchar character;
    bool leaf;
    T value;
    Item[] children;

    this(dchar character, bool leaf) {
        this.character = character;
        this.leaf = leaf;
        this.children = [];
    }
};

class DataTrie(T) {
    Item!T root = Item!T('0', false);

    this() {
    }

    void add(string str, T value) {
        add(&root, str, 0, value);
    }

    bool check(string str) {
        return check(root, str, 0);
    }

    uint length() {
        return length(root);
    }

    T get(string str) {
        return get(root, str, 0);
    }

    void walker(void delegate(string name, int value) func) {
        walker(root, "", func);
    }

    private {
        void add(Item!T* item, string str, uint index, T value) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                item.leaf = true;
                item.value = value;
            } else {
                dchar character = str[index];
                foreach (ref child; item.children) {
                    if (child.character == character) {
                        add(&child, str, index+1, value);
                        return;
                    }
                }
                // no entry found; create new one
                item.children.length += 1;
                item.children[item.children.length-1] = Item!T(character, isLastCharacter);
                add(&item.children[item.children.length-1], str, index+1, value);
            }
        }

        bool check(Item!T item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                return item.leaf;
            } else {
                dchar character = str[index];
                foreach (ref child; item.children) {
                    if (child.character == character) {
                        return check(child, str, index+1);
                    }
                }
                return false;
            }
        }

        T get(Item!T item, string str, uint index) {
            bool isLastCharacter = index == str.length;
            if (isLastCharacter) {
                return item.leaf;
            } else {
                dchar character = str[index];
                foreach (ref child; item.children) {
                    if (child.character == character) {
                        return check(child, str, index+1);
                    }
                }
                return T.init;
            }
        }

        uint length(Item!T item) {
            // TODO
            uint result = 0;
            if (item.leaf) {
                result += 1;
            }
            foreach (ref child; item.children) {
                result += length(child);
            }
            return result;
        }
    
        void walker(Item!T item, string partialValue, void delegate(string value, T value) func) {
            if (item.leaf) {
                func(partialValue, item.value);
            }
            foreach (ref child; item.children) {
                walker(child, partialValue ~ to!string(child.character), func);
            }


        }
    }
};

unittest {

    auto trie = new DataTrie!int();

    assert(trie.length() == 0);
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

    import std.file;
    import std.string;

    if (exists("/usr/share/dict/words")) {
        writeln("Testing many words");
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
        writeln("Testing many words (2)");
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
    writeln(trie.length());

    uint count = 0;
    trie.walker(delegate (string name, int value) { count += 1; });
    assert(count == trie.length());

}

