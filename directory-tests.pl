#! /usr/bin/perl -w

open(FOO, "ospfsmod.c") || die "Did you delete ospfsmod.c?";
$lines = 0;
$lines++ while defined($_ = <FOO>);
close FOO;

@tests = (
    # ls of root directory 
   [ 'ls / -m',
      "bin, boot, cow, dev, etc, home, initrd, initrd.img, lib, live_media, media, mnt, opt, proc, root, sbin, srv, sys, tmp, usr, var, vmlinuz"
    ],
    # ls of root with -F flag n
    [ 'ls -Fm /',
      "bin/, boot/, cow/, dev/, etc/, home/, initrd/, initrd.img@, lib/, live_media/, media/, mnt/, opt/, proc/, root/, sbin/, srv/, sys/, tmp/, usr/, var/, vmlinuz@"
    ],
    #ls of subdirectory
    [ 'ls  test/subdir',
      "message.txt"
    ],

    #ls of subdirectory using more than one data block placeholder
    [ "ls --block-size=900 test/subdir",
      "message.txt"
    ],
    #ls of subdirectory using indirect data blocks placeholder
    [ "ls --block-size=90 test/subdir",
      "message.txt"
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
