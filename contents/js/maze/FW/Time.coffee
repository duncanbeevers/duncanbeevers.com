FW = @FW ||= {}

chop = (millis) ->
  granularities = [
    1000 # millis per second
    60   # seconds per minute
    60   # minutes per hour
    24   # hours per day
    Infinity
  ]

  remainder = millis

  for granularity in granularities
    amount = remainder % granularity
    remainder = Math.floor(remainder / granularity)
    amount

clockFormat = (millis) ->
  [millis, seconds, minutes, hours, days] = chop(millis)

  parts = [
    # formatPart(days)
    # formatPart(hours)
    formatPart(minutes)
    formatPart(seconds)
    formatPart(millis / 10)
  ].join(":")

formatPart = (n) ->
  i = Math.floor(n)
  if i < 10
    "0#{i}"
  else
    i

# Monotonically increasing time source
# No units are specified or guaranteed
now = -> +(new Date())

FW.Time =
  now: now
  chop: chop
  clockFormat: clockFormat
