import std/osproc
import std/strformat
import std/strutils
import std/sequtils

let outp_last = execProcess("lastlog", args=["-b", "90"], options={poUsePath})

let outp_ent = execProcess("getent", args=["passwd"], options={poUsePath})


iterator get_users*(ent: string): string =
  for line in splitLines(ent):
    let fields = split(line, ':')
    if (len(fields) == 1):
      continue
    if (fields[6] == "/usr/sbin/nologin" or fields[6] == "/bin/false"):
      continue
    yield fields[0]

iterator get_last*(last: string): string =
  let headless = split(last, '\n', 1)[1]
  for line in splitLines(headless):
    if (line == ""):
      continue
    let fields = splitWhitespace(line)
    yield fields[0]

let users = toSeq(get_users(outp_ent))

for user in get_last(outp_last):
  if (user notin users):
    continue
  echo fmt"{user}"
