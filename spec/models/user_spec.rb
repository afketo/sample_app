require 'spec_helper'

describe User do

	before { @user=User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar") }

	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:authenticate) }

	it { should be_valid }
	#COMPRUEBA QUE SE HAYA INTRODUCIDO UN USUARIO
	describe "when name is not present" do
		before { @user.name=" "}
		it { should_not be_valid }
	end
	#COMPRUEBA QUE SE HAYA INTRODUCIDO UN EMAIL
	describe "when email is not present" do
		before {@user.email=" "}
		it { should_not be_valid }
	end
	#COMPRUEBA QUE EL USUARIO NO SEA MAYOR DE 20CARACTERES
	describe "when name is too long" do
		before { @user.name = "a" * 21 }
		it { should_not be_valid }
	end
	#COMPRUEBA EL FORMATO DEL EMAIL
	describe "when email format is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.ot example.user@foo.foo@bar_baz.com foo@bar+baz.com]
			addresses.each do |invalid_address|
				@user.email = invalid_address
				expect(@user).not_to be_valid
			end
		end
	end

	describe "when email format is invalid" do
		it "should be valid" do
			addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			addresses.each do |valid_address|
				@user.email = valid_address
				expect(@user).to be_valid
			end
		end
	end
	#COMPROBAMOS QUE EL EMAIL NO SE REPITA
	describe "when email address is already taken" do
		before do
			user_with_same_email = @user.dup
			user_with_same_email.email = @user.email.upcase
			user_with_same_email.save
		end
		it { should_not be_valid }
	end
	#COMPROBAMOS QUE NO SE PONGA PASSWORD EN BLANCO
	describe "when password is not present" do
		before do
			@user=User.new(name: "Example User", email: "user@example.com", password: " ", password_confirmation: " ")
		end
	it { should_not be_valid }
	end
	#COMPROBAMOS SI LA PASSWORD NO COINCIDE
	describe "when password doesn't match confirmation" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end
	#COMPROBAMOS QUE LA CONTRASENA SEA MAYOR A 6CARACTERES
	describe "with a password that's too short" do
		before { @user.password = @user.password_confirmation = "a" * 5 }
		it { should be_invalid }
	end

	#COMPROBAMOS LA AUTENTICACION
	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by(email: @user.email) }
	#SI LA PASSWORD ES CORRECTA CON EL USUARIO
		describe "with valid password" do
			it { should eq found_user.authenticate(@user.password) }
		end
	#SI LA PASSWORD NO ES CORRECTA CON EL USUARIO
		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }
			it { should_not eq user_for_invalid_password }
			specify { expect(user_for_invalid_password).to be_false }
		end
	end
end
