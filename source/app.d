import std.stdio;
import std.file;
import std.string;
import trie_data;

void main()
{
    auto trie = new DataTrie!string();

    if (exists("/usr/share/dict/words")) {
        File file = File("/usr/share/dict/words", "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
                trie.add(line, line);
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
                trie.add(line, line);
            }
        }

        foreach (line; lines) {
            assert(trie.check(line));
        }
    }

}
