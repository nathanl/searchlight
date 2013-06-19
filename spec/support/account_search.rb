class AccountSearch < Searchlight::Search

  search_on MockModel

  searches :paid_amount, :business_name, :balance, :active
  attr_accessor :other_attribute

  def search_paid_amount
    search.where('amount > ?', paid_amount)
  end

  def search_business_name
    search.where(business_name: business_name)
  end

end
