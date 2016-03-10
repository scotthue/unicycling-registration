require 'upload'

class HeatLaneLifImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def process(file, heat)
    upload = Upload.new
    raw_data = upload.extract_csv(file)
    raise StandardError.new("Competition not set for lane assignments") unless @competition.uses_lane_assignments?
    self.num_rows_processed = 0
    self.errors = nil
    raw_data.shift # drop header row
    begin
      HeatLaneResult.transaction do
        raw_data.each do |raw|
          lif_hash = upload.convert_lif_to_hash(raw)
          lane = lif_hash[:lane]

          result = HeatLaneResult.new(
            entered_by: @user,
            entered_at: DateTime.now,
            heat: heat,
            lane: lane,
            raw_data: raw,
            competition: @competition,
            minutes: lif_hash[:minutes],
            seconds: lif_hash[:seconds],
            thousands: lif_hash[:thousands],
            status: (lif_hash[:disqualified] ? "DQ" : "active")
          )
          if result.save!
            self.num_rows_processed += 1
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => invalid
      @errors = invalid
      return false
    end
    true
  end
end