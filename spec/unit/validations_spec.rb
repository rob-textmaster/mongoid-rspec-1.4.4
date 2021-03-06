require 'spec_helper'

describe "Validations" do
  describe Site do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe User do
    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login).scoped_to(:site) }
    it { should validate_uniqueness_of(:email).case_insensitive.with_message("is already taken") }
    it { should validate_format_of(:login).to_allow("valid_login").not_to_allow("invalid login") }
    it { should validate_associated(:profile) }
    it { should validate_inclusion_of(:role).to_allow("admin", "member") }
    it { should validate_confirmation_of(:email) }
    it { should validate_inclusion_of(:admin_rights).to_allow(User::ADMIN_RIGHTS).if(:admin?) }

    it { should validate_inclusion_of(:admin_rights).to_allow(User::ADMIN_RIGHTS).if(:admin?) }
    it { should_not validate_inclusion_of(:admin_rights).to_allow(User::ADMIN_RIGHTS).unless(:admin?) }
    it { should_not validate_inclusion_of(:admin_rights).to_allow(User::ADMIN_RIGHTS) }

    it { should validate_numericality_of(:age).to_allow(:greater_than => 18).unless('admin?') }
    it { should_not validate_numericality_of(:age).to_allow(:greater_than => 18).if('admin?') }
    it { should_not validate_numericality_of(:age).to_allow(:greater_than => 18) }
  end

  describe Profile do
    it { should validate_numericality_of(:age).greater_than(0) }
  end

  describe Article do
    it { should validate_length_of(:title).within(8..16) }
  end

  describe MovieArticle do
    it { should validate_numericality_of(:rating).greater_than(0) }
    it { should validate_numericality_of(:rating).to_allow(:greater_than => 0).less_than_or_equal_to(5) }
    it { should validate_numericality_of(:classification).to_allow(:even => true, :only_integer => true, :nil => false) }
  end
end
