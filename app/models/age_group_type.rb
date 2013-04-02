class AgeGroupType < ActiveRecord::Base
  attr_accessible :name, :description

  validates :name, :presence => true, :uniqueness => true

  has_many :age_group_entries, :dependent => :destroy

  # Return the age group entry that meets the given age requirements
  def age_group_entry_for(age, gender)
    age_group_entries.where("start_age <= :age AND :age <= end_age AND (gender = 'Mixed' OR gender = :gender)", 
                            :age => age, :gender => gender).first
  end

  def as_json(options={})
    options = {
      :except => [:id, :updated_at, :created_at],
      :methods => [:age_group_entries]
    }
    super(options)
  end

  def to_s
    name
  end
end
