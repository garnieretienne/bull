module Bull
  module Monit
    # Get status message with a status code
    # sources:
    #   event.c => messages
    #   event.h => status codes (hex)
    class Event
      @@event_table = {
        'Event_Action'     => ["Action done",             "Action done",                "Action done",              "Action done"],
        'Event_Checksum'   => ["Checksum failed",         "Checksum succeeded",         "Checksum changed",         "Checksum not changed"],
        'Event_Connection' => ["Connection failed",       "Connection succeeded",       "Connection changed",       "Connection not changed"],
        'Event_Content'    => ["Content failed",          "Content succeeded",          "Content match",            "Content doesn't match"],
        'Event_Data'       => ["Data access error",       "Data access succeeded",      "Data access changed",      "Data access not changed"],
        'Event_Exec'       => ["Execution failed",        "Execution succeeded",        "Execution changed",        "Execution not changed"],
        'Event_Fsflag'     => ["Filesystem flags failed", "Filesystem flags succeeded", "Filesystem flags changed", "Filesystem flags not changed"],
        'Event_Gid'        => ["GID failed",              "GID succeeded",              "GID changed",              "GID not changed"],
        'Event_Heartbeat'  => ["Heartbeat failed",        "Heartbeat succeeded",        "Heartbeat changed",        "Heartbeat not changed"],
        'Event_Icmp'       => ["ICMP failed",             "ICMP succeeded",             "ICMP changed",             "ICMP not changed"],
        'Event_Instance'   => ["Monit instance failed",   "Monit instance succeeded",   "Monit instance changed",   "Monit instance not changed"],
        'Event_Invalid'    => ["Invalid type",            "Type succeeded",             "Type changed",             "Type not changed"],
        'Event_Nonexist'   => ["Does not exist",          "Exists",                     "Existence changed",        "Existence not changed"],
        'Event_Permission' => ["Permission failed",       "Permission succeeded",       "Permission changed",       "Permission not changed"],
        'Event_Pid'        => ["PID failed",              "PID succeeded",              "PID changed",              "PID not changed"],
        'Event_PPid'       => ["PPID failed",             "PPID succeeded",             "PPID changed",             "PPID not changed"],
        'Event_Resource'   => ["Resource limit matched",  "Resource limit succeeded",   "Resource limit changed",   "Resource limit not changed"],
        'Event_Size'       => ["Size failed",             "Size succeeded",             "Size changed",             "Size not changed"],
        'Event_Timeout'    => ["Timeout",                 "Timeout recovery",           "Timeout changed",          "Timeout not changed"],
        'Event_Timestamp'  => ["Timestamp failed",        "Timestamp succeeded",        "Timestamp changed",        "Timestamp not changed"],
        'Event_Uid'        => ["UID failed",              "UID succeeded",              "UID changed",              "UID not changed"],
        'Event_Null'       => ["No Event",                "No Event",                   "No Event",                 "No Event"],
      }
      

      @@enum = {
        0x0        => 'Event_Null',
        0x1        => 'Event_Checksum',
        0x2        => 'Event_Resource',
        0x4        => 'Event_Timeout',
        0x8        => 'Event_Timestamp',
        0x10       => 'Event_Size',
        0x20       => 'Event_Connection',
        0x40       => 'Event_Permission',
        0x80       => 'Event_Uid',
        0x100      => 'Event_Gid',
        0x200      => 'Event_Nonexist',
        0x400      => 'Event_Invalid',
        0x800      => 'Event_Data',
        0x1000     => 'Event_Exec',
        0x2000     => 'Event_Fsflag',
        0x4000     => 'Event_Icmp',
        0x8000     => 'Event_Content',
        0x10000    => 'Event_Instance',
        0x20000    => 'Event_Action',
        0x40000    => 'Event_Pid',
        0x80000    => 'Event_PPid',
        0x100000   => 'Event_Heartbeat',
        0xFFFFFFFF => 'Event_All',
      }

      def self.message(code, hint)
        @@event_table[@@enum[code]][hint]
      end
    end
  end
end
