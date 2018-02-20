require 'csv'

path = "C:\\Users\\E6430\\Documents\\ruby programs\\personalizer\\a.csv"

class Code
	@@code_quant = 0
	attr_accessor:code, :num
	def initialize(code)
		@@code_quant += 1
		@code = code #code value
		@num = @@code_quant #code number
	end
end
class Batch
	@@batch_quant = 0
	
	attr_accessor:collection, :num
	def initialize
		@@batch_quant += 1 
		@collection = [] #collection of Codes objects
		@num = @@batch_quant #gets id
	end
	
	def add_code(code)
		@collection << code
	end
	
	def to_s
		print "Batch number: #{@num}. Contains codes from #{@collection[0].num} to #{@collection[-1].num}."
	end
end

class Bundle
	attr_accessor:bundle
	def initialize
		@bundle = [] #the collection of batches
	end
	
	def create_bundle(base,per_batch) #per_batch determines how many codes are in single batch.
		while base.all_codes != [] #it will shift (pop first element) codes from our list. If there's no more codes left the loop will stop.
			tmp_batch = Batch.new
			per_batch.times do |jmp| # this loop is adding codes to the batches
				if base.all_codes == [] #it checks if there are still some codes left, we don't want nils in our batch
					break
				end
				tmp_batch.add_code(base.all_codes.shift) 
			end
			@bundle << tmp_batch #adds batch to the collection of batches
		end
	end
end

class Base
	attr_accessor:all_codes
	def initialize(file) #file is the path to the .csv, 
		@all_codes = [] #array of all codes, elements will be popped out when filling batches
		CSV.foreach(file) do |row| #this one will take all values from csv and put into temporary array
			@all_codes << Code.new(row[0]) #row from csv is a table, but we need a value of it that's why we use "row[0]"
		end	
	end	
end

db = Base.new(path)
x = Bundle.new
x.create_bundle(db,3)
puts x.bundle