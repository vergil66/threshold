#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use Time::Piece;
use File::Path qw(make_path);

my $DATA_DIR   = "data";
my $EXPORT_DIR = "exports";

make_path($DATA_DIR);
make_path($EXPORT_DIR);

my $today = localtime->ymd;
my $file  = "$DATA_DIR/$today.json";

my $command = shift @ARGV || "menu";

sub load_day {
    return {
        date => $today,
        entries => [],
        weekly_reflection => ""
    } unless -e $file;

    open my $fh, "<", $file or die "Cannot open $file: $!";
    local $/;
    my $json = <$fh>;
    close $fh;

    return decode_json($json);
}

sub save_day {
    my ($day) = @_;
    open my $fh, ">", $file or die "Cannot write $file: $!";
    print $fh encode_json($day);
    close $fh;
}

sub prompt {
    my ($label) = @_;
    print "$label: ";
    chomp(my $input = <STDIN>);
    return $input;
}

sub add_entry {
    my $day = load_day();

    print "\nThreshold — Add Teaching Entry\n\n";

    my $entry = {
        time       => localtime->hms,
        
        period     => prompt("Period"),
        section    => prompt("Section / Term"),
        course     => prompt("Course"),
        
        focus      => prompt("Lesson focus / main movement"),
        plan       => prompt("Basic plan / class sequence"),
        
        transition => prompt("Transition moment to notice"),
        
        engage     => prompt("Engage — where did connection or attention happen?"),
        reduce     => prompt("Reduce — what could be lighter or simpler?"),
        persist    => prompt("Persist — what is worth continuing?"),
        
        reflection => prompt("Reflection — what actually happened?"),
        followup   => prompt("Follow-up / next action"),
    };

    push @{ $day->{entries} }, $entry;
    save_day($day);

    print "\nSaved entry for $entry->{course} / $entry->{period}.\n";
}

sub view_today {
    my $day = load_day();

    print "\nThreshold — $day->{date}\n";
    print "=" x 40, "\n\n";

    unless (@{ $day->{entries} }) {
        print "No entries yet today.\n";
        return;
    }

    for my $entry (@{ $day->{entries} }) {
        print "[$entry->{time}] $entry->{period} — $entry->{course}";
        print " ($entry->{section})" if $entry->{section};
        print "\n";
        print "Focus: $entry->{focus}\n";
        print "Plan: $entry->{plan}\n";
        print "Transition: $entry->{transition}\n";
        print "Engage: $entry->{engage}\n";
        print "Reduce: $entry->{reduce}\n";
        print "Persist: $entry->{persist}\n";
        print "Reflection: $entry->{reflection}\n";
        print "Follow-up: $entry->{followup}\n";
        print "-" x 40, "\n";
    }
}

sub weekly_reflection {
    my $day = load_day();

    print "\nThreshold — Weekly Reflection\n\n";
    $day->{weekly_reflection} = prompt("What changed in the room this week?");

    save_day($day);

    print "\nWeekly reflection saved.\n";
}

sub export_markdown {
    my $day = load_day();
    my $out = "$EXPORT_DIR/$today.md";

    open my $fh, ">", $out or die "Cannot write $out: $!";

    print $fh "# Threshold Daybook — $day->{date}\n\n";

    for my $entry (@{ $day->{entries} }) {
        print $fh "## $entry->{period} — $entry->{course}";
        print $fh " ($entry->{section})" if $entry->{section};
        print $fh "\n\n";
        print $fh "**Time:** $entry->{time}\n\n";
        print $fh "**Focus:** $entry->{focus}\n\n";
        print $fh "**Plan:** $entry->{plan}\n\n";
        print $fh "**Transition Moment:** $entry->{transition}\n\n";
        print $fh "**Engage:** $entry->{engage}\n\n";
        print $fh "**Reduce:** $entry->{reduce}\n\n";
        print $fh "**Persist:** $entry->{persist}\n\n";
        print $fh "**Reflection:** $entry->{reflection}\n\n";
        print $fh "**Follow-up:** $entry->{followup}\n\n";
        print $fh "---\n\n";
    }

    if ($day->{weekly_reflection}) {
        print $fh "## Weekly Reflection\n\n";
        print $fh "$day->{weekly_reflection}\n\n";
    }

    close $fh;

    print "\nExported to $out\n";
}

sub menu {
    print "\nThreshold Daybook\n";
    print "A classroom practice for noticing what changes in the room.\n\n";
    print "1. Add teaching entry\n";
    print "2. View today\n";
    print "3. Weekly reflection\n";
    print "4. Export markdown\n\n";

    my $choice = prompt("Choose");

    if    ($choice eq "1") { add_entry(); }
    elsif ($choice eq "2") { view_today(); }
    elsif ($choice eq "3") { weekly_reflection(); }
    elsif ($choice eq "4") { export_markdown(); }
    else { print "No action taken.\n"; }
}

if    ($command eq "add")     { add_entry(); }
elsif ($command eq "today")   { view_today(); }
elsif ($command eq "week")    { weekly_reflection(); }
elsif ($command eq "export")  { export_markdown(); }
else                          { menu(); }