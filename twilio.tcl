#!/usr/bin/env tclsh

# twilio.tcl --
#
#   This is a short demo of how to send a SMS or a MMS message from TCL/Tk
#   with the power of the Twilio APIs (and the GUI productivity of Tk!).
#   You can use the ::twilio::send_sms{} function piecemeal for your own
#   applications.
#
#   License: MIT
#
#   Installation is platform dependent; many POSIX compliant systems have TCL
#   installed, however (try 'tcl' then <tab> completing).  On recent
#   versions of OSX, for example, you can run this with:
#
# > tclsh8.6 twilio.tcl
#
# Because we are using the ttk widets, *you'll need at least TCL 8.5.*
#
# You will need to set:
#
#   TWILIO_AUTH_TOKEN
#   TWILIO_PHONE_NUMBER
#   TWILIO_ACCOUNT_SID
#
# as environment variables.  Then, merely run and fill out the Tk form
# with a destination phone number, a message body, and an optional image URL.

package require http
package require tls
package require base64
package require Tk

# Put all our functions into the twilio namespace
namespace eval twilio {
    # Get environment variables
    set phone_number $::env(TWILIO_PHONE_NUMBER)
    set account_sid $::env(TWILIO_ACCOUNT_SID)
    set auth_token $::env(TWILIO_AUTH_TOKEN)

    # Base URL for the Twilio Messaging API
    set url \
        "https://api.twilio.com/2010-04-01/Accounts/${account_sid}/Messages"

    # twilio::build_auth_headers --
    #
    #   Use Base64 to build a Basic Authorization header.
    #
    #   Arguments:
    #       username, password which maps to ACCOUNT_SID and AUTH_TOKEN
    #   Results:
    #       A string with the Basic Authorization header

    proc build_auth_headers {username password} {

        return "Basic [base64::encode $username:$password]"
    }

    # twilio::submit_form --
    #
    #   Submit the Tk Twilio message form
    #
    #   Arguments:
    #       None (gets them from the form)
    #   Results:
    #       None (it sends an SMS or MMS)
    proc submit_form {} {
        # Get the form parameters and send a text
        set form_body [.c.body get 1.0 end]
        if {[string length form_body] <= 1} {
            set ::result "Please add a body."
            return
        }

        if { [catch { set form_to $::form_to } ] } {
            set ::result "Check phone number."
            return
        }
        if { [catch { set image_url $::form_image } ] } {
            set image_url ""
        }

        send_sms                        \
            $form_to                    \
            $::twilio::phone_number     \
            $form_body                  \
            $::twilio::account_sid      \
            $::twilio::auth_token       \
            $image_url

        # Now delete everything; we don't want the user to send twice.
        .c.body delete 1.0 end

        # Give a nice result to our user
        set ::result "You sent it!"
    }

    # twilio::send_sms --
    #
    #   Sends an SMS or MMS with Twilio.  (Get the required variables from
    #   the Twilio console.)
    #
    #   Arguments:
    #       to, from - the number to send the message to and from where
    #       body - body text to send
    #       account_sid - Twilio account SID
    #       auth_token - Twilio auth token
    #   Results:
    #       false if we failed, true if Twilio returns a 2XX.  Also dumps
    #       Twilio's response to standard out.

    proc send_sms {to from body account_sid auth_token {image_url ""}} {
        ::tls::init -tls1 1 -ssl3 0 -ssl2 0
        http::register https 443 \
            [list ::tls::socket -request 1 -require 1 -cafile ./server.pem]


        # Escape the URL characters, optionally add media
        if {[string length $image_url] == 0} {
            set html_parameters                         \
                [::http::formatQuery                    \
                    "From"  $from                       \
                    "To"    $to                         \
                    "Body"  $body                       \
                ]
        } else {
            set html_parameters                         \
                [::http::formatQuery                    \
                    "From"      $from                   \
                    "To"        $to                     \
                    "Body"      $body                   \
                    "MediaUrl"  $image_url              \
                ]
        }

        # Make a POST request to Twilio
        set tok [                                   \
            ::http::geturl $::twilio::url           \
                -query $html_parameters             \
                -headers [list                      \
                    "Authorization"                 \
                    [                               \
                        build_auth_headers          \
                        $account_sid                \
                        $auth_token                 \
                    ]                               \
                ]                                   \
        ]

        # HTTP Response: print it to command line if we failed...
        if {[string first "20" [::http::code $tok]] != -1} {
            puts [::http::code $tok]
            puts [::http::data $tok]
            return false
        } else {
            return true
        }
    }
}

# init_gui --
#
#   Initialize the GUI for the TCL/Tk Twilio demo.
#
#   Arguments:
#       None
#   Results:
#       None (it creates the GUI)

proc init_gui {} {
    # Set up the nice GUI we'll present to our end user.
    wm title . "Twilio SMS/MMS Demo with TCL/Tk!"
    grid [ttk::frame .c -padding "2 2 20 40"]                           \
        -column 0                                                       \
        -row 0                                                          \
        -sticky nwes

    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1

    grid [ttk::label .c.tolbl -text "To:"]                              \
        -column 1                                                       \
        -row 1                                                          \
        -sticky w

    grid [ttk::entry .c.to_number -width 20 -textvariable form_to]      \
        -column 2                                                       \
        -row 1                                                          \
        -sticky we

    grid [ttk::label .c.bodylbl -text "Body:"]                          \
        -column 1                                                       \
        -row 2                                                          \
        -sticky w

    grid [text .c.body -width 20 -height 8]                             \
        -column 2                                                       \
        -row 2                                                          \
        -sticky we

    grid [ttk::label .c.imlbl -text "Image URL (Optional):"]            \
        -column 1                                                       \
        -row 3                                                          \
        -sticky w

    grid [ttk::entry .c.image_url -width 60 -textvariable form_image]   \
        -column 2                                                       \
        -row 3                                                          \
        -sticky we

    grid [ttk::label .c.meters -textvariable result]                    \
        -column 1                                                       \
        -row 4                                                          \
        -sticky we

    grid                                                                \
        [ttk::button .c.calc                                            \
            -text "Send a Message"                                      \
            -command                                                    \
            ::twilio::submit_form                                       \
        ]                                                               \
        -column 2                                                       \
        -row 4                                                          \
        -sticky w


    # Configure all of the children of c we just set up
    foreach w [winfo children .c] {
        grid configure $w -padx 5 -pady 5
    }

    # Set the initial form function to the 'To' Number field.
    focus .c.to_number
}

# This line makes all the action happen.
init_gui
