ThinkingSphinx::Index.define :os_donation, :with => :active_record do
  indexes contrib
  indexes orgname
  indexes ultorg
  indexes employer

  has amount
  has recipcode
  has transactiontype
end
