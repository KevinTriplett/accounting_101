# there's probably a better way to do this...
# and probably a better place to put this...
class Fixnum
  def minutes; self*60; end
  def hours; self*3600; end
  def days; self*86400; end
end

# REFERENCE:
# %a - The abbreviated weekday name (``Sun'')
# %A - The  full  weekday  name (``Sunday'')
# %b - The abbreviated month name (``Jan'')
# %B - The  full  month  name (``January'')
# %c - The preferred local date and time representation
# %d - Day of the month (01..31)
# %H - Hour of the day, 24-hour clock (00..23)
# %I - Hour of the day, 12-hour clock (01..12)
# %j - Day of the year (001..366)
# %m - Month of the year (01..12)
# %M - Minute of the hour (00..59)
# %p - Meridian indicator (``AM''  or  ``PM'')
# %S - Second of the minute (00..60)
# %U - Week  number  of the current year,
#         starting with the first Sunday as the first
#         day of the first week (00..53)
# %W - Week  number  of the current year,
#         starting with the first Monday as the first
#         day of the first week (00..53)
# %w - Day of the week (Sunday is 0, 0..6)
# %x - Preferred representation for the date alone, no time
# %X - Preferred representation for the time alone, no date
# %y - Year without a century (00..99)
# %Y - Year with century
# %Z - Time zone name
# %% - Literal ``%'' character

Time::DATE_FORMATS.merge!(
  :smart => lambda { |time|
    if time.year == Time.now.year
      if time.to_date == Time.now.to_date
        time.strftime("%I:%M %p").sub(/^0/, "")
      else
        time.strftime "%b #{time.day.ordinalize}"
      end
    else
      time.strftime "%b #{time.day.ordinalize}, %Y"
    end
  },
  :long => lambda { |time|
    time.strftime "%B #{time.day.ordinalize}, %Y"
  },
  :medium => lambda { |time|
    time.strftime "%b #{time.day.ordinalize}, %y"
  },
  :short => lambda { |time|
    time.strftime "%B #{time.day.ordinalize}"
  },
  :time => lambda { |time|
    time.strftime("%I:%M %p").sub(/^0/, "")
  },
  :summary => lambda { |time|
    time_string = time.strftime("%I:%M").sub(/^0/, "")
    # time_string += time.hour >= 12 ? " Morning" : " Afternoon"
    time_string += time.strftime(" %p")
    date_string = if time.year == Time.now.year
      if time.to_date == Time.now.to_date
        time.strftime "TODAY, %b #{time.day}"
      else
        time.strftime "%a, %b #{time.day}"
      end
    else
      time.strftime "%a %b #{time.day}, %Y"
    end
    "#{date_string} (#{time_string})"
  },
  :summary_date => lambda { |time|
    date_string = if time.year == Time.now.year
      if time.to_date == Time.now.to_date
        time.strftime "TODAY, %b #{time.day}"
      else
        time.strftime "%a, %b #{time.day}"
      end
    else
      time.strftime "%a %b #{time.day}, %Y"
    end
    "#{date_string}"
  },
  :default => lambda { |time|
    time.strftime "%B #{time.day.ordinalize}, %Y (%I:%M %p)"
  }
)
