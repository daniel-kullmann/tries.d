import std.conv;
import std.datetime;
import std.file;
import std.stdio;
import std.string;
import trie_data;

alias Trie = DataTrie!string;
alias AA = string[string];

void testWordFile(Trie trie, string filename, uint multiples) {
    if (exists(filename)) {

        StopWatch sw;
        sw.reset();
        sw.start();
        File file = File(filename, "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
            }
        }
        sw.stop();
        writeln("Read in " , lines.length, " lines in ", sw.peek().msecs, " ms");

        sw.reset();
        sw.start();
        uint numItems = 0;
        foreach (line; lines) {
            auto addLine = line;
            for (auto idx = 0; idx<multiples; idx++) {
                trie.add(addLine, line);
                addLine ~= line;
                numItems++;
            }
        }
        sw.stop();
        writeln("Added ", numItems, " items in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(numItems), " us/item");

        sw.reset();
        sw.start();
        foreach (line; lines) {
            auto addLine = line;
            for (auto idx = 0; idx<multiples; idx++) {
                trie.add(addLine, line);
                addLine ~= line;
            }
        }
        sw.stop();
        writeln("Added ", numItems, " items again in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(numItems), " us/item");

        sw.reset();
        sw.start();
        foreach (line; lines) {
            assert(trie.check(line));
        }
        sw.stop();
        writeln("Checked ", trie.length, " items in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(trie.length), " us/item");

        uint count = 0;
        trie.walker(delegate(string name, string value) {
            count += name.length;
        });
        writeln("Trie stores strings of length " ~ to!string(count) ~ "");

        foreach (line; lines) {
           trie.remove(line);
        }
        sw.stop();
        writeln("Removed ", lines.length, " items again in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(lines.length), " us/item");

        foreach (line; lines) {
            assert(!trie.check(line));
        }
    }
}

void testWordFile(AA aa, string filename, uint multiples) {
    if (exists(filename)) {

        StopWatch sw;
        sw.reset();
        sw.start();
        File file = File(filename, "r");
        string[] lines;
        while (!file.eof()) {
            string line = chomp(file.readln());
            if (line != "") {
                lines.length += 1;
                lines[lines.length-1] = line;
            }
        }
        sw.stop();
        writeln("Read in " , lines.length, " lines in ", sw.peek().msecs, " ms");

        sw.reset();
        sw.start();
        uint numItems = 0;
        foreach (line; lines) {
            auto addLine = line;
            for (auto idx = 0; idx<multiples; idx++) {
                aa[addLine] = line;
                addLine ~= line;
                numItems++;
            }
        }
        sw.stop();
        writeln("Added ", numItems, " items in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(numItems), " us/item");

        sw.reset();
        sw.start();
        foreach (line; lines) {
            auto addLine = line;
            for (auto idx = 0; idx<multiples; idx++) {
                aa[addLine] = line;
                addLine ~= line;
            }
        }
        sw.stop();
        writeln("Added ", numItems, " items again in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(numItems), " us/item");

        sw.reset();
        sw.start();
        foreach (line; lines) {
            assert(line in aa);
        }
        sw.stop();
        writeln("Checked ", aa.length, " items in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(aa.length), " us/item");

        uint count = 0;
        foreach(name, ref value; aa) {
            count += name.length;
        }
        writeln("AA stores strings of length " ~ to!string(count) ~ "");

        foreach (line; lines) {
           aa.remove(line);
        }
        sw.stop();
        writeln("Removed ", lines.length, " items again in ", sw.peek().msecs, " ms; ", 
                1000 * to!double(sw.peek().msecs) / to!double(lines.length), " us/item");

        foreach (line; lines) {
            assert(!(line in aa));
        }
    }
}

void main()
{
    string[string] aa;

    writeln("# AA");
    testWordFile(aa, "/usr/share/dict/cracklib-small", 10);
    testWordFile(aa, "/usr/share/dict/american-english", 5);
    testWordFile(aa, "/usr/share/dict/american-english-insane", 2);

    aa = null;

    writeln("");

    auto trie = new Trie();

    writeln("# Trie");
    testWordFile(trie, "/usr/share/dict/cracklib-small", 10);
    testWordFile(trie, "/usr/share/dict/american-english", 5);
    testWordFile(trie, "/usr/share/dict/american-english-insane", 2);

    trie = null;

}
