class TwoAttemptEntryAdvancedImporter < BaseImporter
  # Create TwoAttemptEntry records from a file.
  def process(file, start_times)
    return false unless valid_file?(file)

    upload = Upload.new(";")
    raw_data = upload.extract_csv(file)
    self.num_rows_processed = 0
    self.errors = nil
    is_start_time = start_times || false
    TwoAttemptEntry.transaction do
      raw_data.each do |raw|
        entry = build_entry(is_start_time, raw)

        if entry.present? && entry.save!
          self.num_rows_processed += 1
        end
      end
    end
    true
  rescue ActiveRecord::RecordInvalid => invalid
    @errors = invalid
    return false
  end

  # Example data
  # 30;Smith;Ramona;19,64;19,40;Switzerland;23;w;IUF-Slalom
  # 65;Rondeau;Antoine;24,66;disq;France;22;m;IUF-Slalom
  # 268;Jorgensen;Jonas ;abgem;abgem;Denmark;20;m;IUF-Slalom
  def build_entry(is_start_time, raw)
    time_one = raw[3]
    time_two = raw[4]
    status_1 = translate_status_column(time_one)
    status_2 = translate_status_column(time_two)

    return nil if status_1.nil? && status_2.nil?
    minutes_1, seconds_1, thousands_1 = nil
    minutes_2, seconds_2, thousands_2 = nil

    if status_1 == "active"
      broken_apart = time_one.split(",")
      minutes_1 = 0
      seconds_1 = broken_apart[0]
      thousands_1 = broken_apart[1].to_i * 10
    end

    if status_2 == "active"
      broken_apart = time_two.split(",")
      minutes_2 = 0
      seconds_2 = broken_apart[0]
      thousands_2 = broken_apart[1].to_i * 10
    end

    TwoAttemptEntry.new(
      competition: competition,
      user: user,
      bib_number: raw[0],
      minutes_1: minutes_1,
      seconds_1: seconds_1,
      thousands_1: thousands_1,
      status_1: status_1,

      minutes_2: minutes_2,
      seconds_2: seconds_2,
      thousands_2: thousands_2,
      status_2: status_2,
      is_start_time: is_start_time
    )
  end

  def translate_status_column(data)
    case data
    when "", nil
      nil
    when "disq"
      "DQ"
    when "abgem"
      "DQ"
    else
      "active"
    end
  end
end