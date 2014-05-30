class SetMemberSubject < ActiveRecord::Base
  belongs_to :subject_set
  belongs_to :subject

  enum state: [:active, :inactive, :retired]

  validates_presence_of :subject_set, :subject
end