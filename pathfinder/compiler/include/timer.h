/* -*- c-basic-offset:4; c-indentation-style:"k&r"; indent-tabs-mode:nil -*- */

/**
 * @file
 *
 * Pathfinder timer services (resolution microseconds): start/stop
 * timer, convert timer value into formatted string representation.
 *
 *
 * Copyright Notice:
 * -----------------
 *
 * The contents of this file are subject to the Pathfinder Public License
 * Version 1.1 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://monetdb.cwi.nl/Legal/PathfinderLicense-1.1.html
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied.  See
 * the License for the specific language governing rights and limitations
 * under the License.
 *
 * The Original Code is the Pathfinder system.
 *
 * The Original Code has initially been developed by the Database &
 * Information Systems Group at the University of Konstanz, Germany and
 * is now maintained by the Database Systems Group at the Technische
 * Universitaet Muenchen, Germany.  Portions created by the University of
 * Konstanz and the Technische Universitaet Muenchen are Copyright (C)
 * 2000-2005 University of Konstanz and (C) 2005-2006 Technische
 * Universitaet Muenchen, respectively.  All Rights Reserved.
 *
 * $Id$
 */

#ifndef TIMER_H
#define TIMER_H

/**
 * Start a new timer.  Later, when you stop and want to read off the
 * timer's elapsed time, you need to pass the return value of this
 * function to #PFtimer_stop ().  This allows for several concurrent
 * timers running ``in parallel''.
 *
 * @return timer value to be passed to PFtimer_stop ()
 */
long
PFtimer_start (void);

/**
 * Stop an already running timer and read off its current elapsed time
 * (the returned value indicates elapsed microseconds).  You can
 * ``stop'' the same timer more than once.
 *
 * @param start the timer's start time returned by #PFtimer_start ()
 * @return the timer's elapsed time (microseconds)
 */
long
PFtimer_stop (long);

/**
 * Convert a timer's elapsed microseconds value into a formatted string
 * representation suitable to write to log files etc.
 *
 * @param elapsed the timer's elapsed microseconds value (as returned
 *        by #PFtimer_stop ())
 * @return formatted string representation of timer's value
 */
char *
PFtimer_str (long);

#endif

/* vim:set shiftwidth=4 expandtab: */
