#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
    # read first byte of file
    [ 'dd count=1 bs=1 if=./test/pokercats.gif 2>&-',
      "G"
    ],
    #read the first block of a file
    [ 'dd ibs=1024 count=1 if=./test/test1block.txt 2>&-| md5sum',
      "387820c7cfb039ffeff36b5ddafab2ee -"
    ],
    #read half of the first block of a file
    [ 'dd ibs=1024 bs=512 count=1 if=./test/test1block.txt 2>&-|md5sum ',
      "afb2de5db24cc249daff0aa8a6614d7c -"
    ],
    #read starting partway through the first block and into part of the next block
    [ 'dd skip=2 bs=900 if=./base/test1block.txt 2>&- |md5sum',
      "71b480f8a7729d42e4d026e32d89e5e0 -"
    ],

    # read more than one block
    [ 'dd ibs=1024 count=2 if=./test/test1block.txt 2>&-|md5sum',
      'b1c6e475dad4172ffc6ddc8cd13d33bc -'
    ],

    # try to read past the end of a file
    [ 'dd skip=1 count=2 if=./test/hello.txt',
      "dd: `./base/hello.txt': cannot skip to specified offset"
    ],
    
    # need to fix   
    [ 'cat test/a',
    'cat: test/a: No such file or directory'
    ],

);

my($ntest) = 0;
my(@wanttests);

foreach $i (@ARGV) {
    $wanttests[$i] = 1 if (int($i) == $i && $i > 0 && $i <= @tests);
}

my($sh) = "bash";
my($tempfile) = "lab3test.txt";
my($ntestfailed) = 0;
my($ntestdone) = 0;

foreach $test (@tests) {
    $ntest++;
    next if (@wanttests && !$wanttests[$ntest]);
    $ntestdone++;
    print STDOUT "Running test $ntest\n";
    my($in, $want) = @$test;
    open(F, ">$tempfile") || die;
    print F $in, "\n";
    print STDERR "  ", $in, "\n";
    close(F);
    $result = `$sh < $tempfile 2>&1`;
    $result =~ s|\[\d+\]||g;
    $result =~ s|^\s+||g;
    $result =~ s|\s+| |g;
    $result =~ s|\s+$||;

    next if $result eq $want;
    next if $want eq 'Syntax error [NULL]' && $result eq '[NULL]';
    next if $result eq $want;
    print STDERR "Test $ntest FAILED!\n  input was \"$in\"\n  expected output like \"$want\"\n  got \"$result\"\n";
    $ntestfailed += 1;
}

unlink($tempfile);
my($ntestpassed) = $ntestdone - $ntestfailed;
print "$ntestpassed of $ntestdone tests passed\n";
exit(0);
