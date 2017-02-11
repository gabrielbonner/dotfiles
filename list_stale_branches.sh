#!/usr/bin/perl
use strict;
use warnings;
# Perform a 'git fetch' to 

# Verify that the local branch of master has been brought up-to-date.
`git fetch`;
my @missing_commits = `git log master..origin/master`;
if (@missing_commits) {
  die "Error: 'master' is not up-to-date with 'origin/master'";
}

# Collect stale local branches.
my @local_merged = `git branch --merged`;
my @local_zappable;
for (@local_merged) {
  s/^\s+//;
  s/\s+$//;
  if (s/^\*\s*//) {
    # Verify that master is the current branch.
    if ($_ ne 'master') {
      die "Error: checked out branch must be 'master', not '$_'";
    }
  }
  else {
    next if $_ =~ m/HEAD/;
    next if $_ =~ m/\/master$/;
    push @local_zappable, $_;
  }
}

# Collect stale remote branches.
my @remote_merged = `git branch -r --merged`;
my @remote_zappable;
for (@remote_merged) {
  s/^\s+//;
  s/\s+$//;
  next if $_ =~ m/HEAD/;
  next if $_ =~ m/\/master$/;
  push @remote_zappable, $_;
}

# Print out commands.
print "COMMANDS\n";
print "========\n";
for (@local_zappable) {
  print "git branch -d $_\n";
}
for (@remote_zappable) {
  my ($remote,$repo) = split('/',$_); 
  print "git push $remote :$repo\n";
}

