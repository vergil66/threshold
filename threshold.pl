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

my $command = shift @ARGV || "menu";
my $date    = shift @ARGV || localtime->ymd;

sub file_for_date {
    my ($date) = @_;
    return "$DATA_DIR/$date.json";
}

sub load_day {
    my ($date) = @_;
    my $file = file_for_date($date);

    return {
        date => $date,
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
    my $file = file_for_date($day->{date});

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

sub multiline_prompt {
    my ($label) = @_;
    print "$label (finish with a single . on its own line):\n";

    my @lines;

    while (1) {
        chomp(my $line = <STDIN>);
        last if $line eq '.';
        push @lines, $line;
    }

    return join("\n", @lines);
}

sub plan_entry {
    my ($date) = @_;
    my $day = load_day($date);

    print "\nThreshold — Plan Lesson Entry for $date\n";
    print "---------------------------------------\n";
    print "Before Class\n\n";

    my $period     = prompt("Period");
    my $section    = prompt("Section / Term");
    my $course     = prompt("Course");
    my $focus      = prompt("Lesson focus / main movement");
    my $plan       = prompt("Basic plan / class sequence");
    my $transition = prompt("Transition moment to notice");

    my $entry = {
        time       => localtime->hms,
        period     => $period,
        section    => $section,
        course     => $course,
        focus      => $focus,
        plan       => $plan,
        transition => $transition,
        engage     => "",
        reduce     => "",
        persist    => "",
        reflection => "",
        followup   => "",
        completed  => 0,
    };

    push @{ $day->{entries} }, $entry;
    save_day($day);

    print "\nPlanned entry saved for $course / $period on $date.\n";
}

sub reflect_entry {
    my ($date) = @_;
    my $day = load_day($date);

    my @open_entries = grep { !$_->{completed} } @{ $day->{entries} };

    unless (@open_entries) {
        print "\nNo incomplete entries for $date.\n";
        return;
    }

    print "\nThreshold — Reflection for $date\n";
    print "-------------------------------\n\n";

    for my $i (0 .. $#open_entries) {
        my $e = $open_entries[$i];

        my $period  = $e->{period}  || "[no period]";
        my $course  = $e->{course}  || "[no course]";
        my $focus   = $e->{focus}   || "[no focus]";
        my $section = $e->{section} || "";

        print ($i + 1);
        print ". $period — $course";
        print " ($section)" if $section;
        print " | $focus";
        print "\n";
    }

    my $choice = prompt("Choose entry number");

    return unless $choice =~ /^\d+$/;
    return if $choice < 1 || $choice > @open_entries;

    my $entry = $open_entries[$choice - 1];
    
    print "\nPlanned Lesson\n";
    print "--------------\n";
    print "Period: $entry->{period}\n";
    print "Section / Term: $entry->{section}\n" if $entry->{section};
    print "Course: $entry->{course}\n";
    print "Focus: $entry->{focus}\n";
    print "Plan: $entry->{plan}\n";
    print "Transition to notice: $entry->{transition}\n";

    print "\nAfter Class\n\n";

    $entry->{engage}     = prompt("Engage — where did connection or attention happen?");
    $entry->{reduce}     = prompt("Reduce — what could be lighter or simpler?");
    $entry->{persist}    = prompt("Persist — what is worth continuing?");
    $entry->{reflection} = multiline_prompt("Reflection — what actually happened?");
    $entry->{followup}   = multiline_prompt("Follow-up / next action");

    $entry->{completed} = 1;

    save_day($day);

    print "\nReflection saved for $date.\n";
}

sub view_day {
    my ($date) = @_;
    my $day = load_day($date);

    print "\nThreshold — $day->{date}\n";
    print "=" x 40, "\n\n";

    unless (@{ $day->{entries} }) {
        print "No entries for this date.\n";
        return;
    }

    for my $i (0 .. $#{ $day->{entries} }) {
        my $entry = $day->{entries}->[$i];
        my $status = $entry->{completed} ? "Complete" : "Planned";

        print ($i + 1) . ". ";
        print "[$status] ";
        print "[$entry->{time}] ";
        print "$entry->{period} — $entry->{course}";
        print " ($entry->{section})" if $entry->{section};
        print "\n";

        print "Focus: $entry->{focus}\n";
        print "Plan: $entry->{plan}\n";
        print "Transition: $entry->{transition}\n";

        if ($entry->{completed}) {
            print "Engage: $entry->{engage}\n";
            print "Reduce: $entry->{reduce}\n";
            print "Persist: $entry->{persist}\n";
            print "Reflection: $entry->{reflection}\n";
            print "Follow-up: $entry->{followup}\n";
        }

        print "\n", "-" x 50, "\n\n";
    }
}

sub weekly_reflection {
    my ($date) = @_;
    my $day = load_day($date);

    print "\nThreshold — Weekly Reflection for $date\n\n";
    $day->{weekly_reflection} = multiline_prompt("What changed in the room this week?");

    save_day($day);

    print "\nWeekly reflection saved for $date.\n";
}

sub export_markdown {
    my ($date) = @_;
    my $day = load_day($date);
    my $out = "$EXPORT_DIR/$date.md";

    open my $fh, ">", $out or die "Cannot write $out: $!";

    print $fh "# Threshold Daybook — $day->{date}\n\n";

    for my $i (0 .. $#{ $day->{entries} }) {
        my $entry = $day->{entries}->[$i];
        my $status = $entry->{completed} ? "Complete" : "Planned";

        print $fh "## $entry->{period} — $entry->{course}";
        print $fh " ($entry->{section})" if $entry->{section};
        print $fh "\n\n";

        print $fh "**Status:** $status\n\n";
        print $fh "**Time Created:** $entry->{time}\n\n";
        print $fh "**Focus:** $entry->{focus}\n\n";
        print $fh "**Plan:** $entry->{plan}\n\n";
        print $fh "**Transition Moment:** $entry->{transition}\n\n";

        if ($entry->{completed}) {
            print $fh "**Engage:** $entry->{engage}\n\n";
            print $fh "**Reduce:** $entry->{reduce}\n\n";
            print $fh "**Persist:** $entry->{persist}\n\n";
            print $fh "**Reflection:** $entry->{reflection}\n\n";
            print $fh "**Follow-up:** $entry->{followup}\n\n";
        }

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
    print "Working date: $date\n\n";
    print "1. Plan lesson entry\n";
    print "2. Reflect on lesson\n";
    print "3. View day\n";
    print "4. Weekly reflection\n";
    print "5. Export markdown\n\n";

    my $choice = prompt("Choose");

    if    ($choice eq "1") { plan_entry($date); }
    elsif ($choice eq "2") { reflect_entry($date); }
    elsif ($choice eq "3") { view_day($date); }
    elsif ($choice eq "4") { weekly_reflection($date); }
    elsif ($choice eq "5") { export_markdown($date); }
    else { print "No action taken.\n"; }
}

if    ($command eq "plan")    { plan_entry($date); }
elsif ($command eq "reflect") { reflect_entry($date); }
elsif ($command eq "today")   { view_day(localtime->ymd); }
elsif ($command eq "view")    { view_day($date); }
elsif ($command eq "week")    { weekly_reflection($date); }
elsif ($command eq "export")  { export_markdown($date); }
else                          { menu(); }