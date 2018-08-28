#practice 
import copy

def mergesort(array):
	helper = array.copy()
	mergesort1(array, helper, 0, len(array)-1)

def mergesort1(array, helper, low, high):
	print(int(high))
	print(int(low))
	if int(high) > low:
		mergesort1(array, helper, low, int(high/2))
		mergesort1(array, helper, int(high/2)+1, high)
		merge(array, helper, low, high)


def merge(array, helper, low, high):
	x=low
	i = 0
	print(array)
	print(helper)
	print(low)
	print(high)
	while x<high:
		helper[i] = array[x]
		x += 1 
		i += 1

	helper_low = 0
	helper_mid = int((high-low)/2)
	helper_high = high-low

	array_low = low
	array_mid = int(high/2)
	array_high = high

	while (helper_low!=int((high-low)/2)+1 and helper_mid != high-low+1):
		if helper[helper_low]<helper[helper_mid]:
			array[array_low] = helper[helper_low]
			helper_low+=1
		else:
			array[array_low] = helper[helper_mid]
			helper_mid+=1
		array_low+=1

	if helper_low!=int((high-low)/2)+1:
		while helper_mid != high-low+1:
			array[array_low]=helper[helper_mid]
			helper_mid+=1
	else:
		while helper_low!=int((high-low)/2)+1:
			array[array_low]=helper[helper_low]
			helper_low+=1
	print('hello')






def quicksort(array, left, right):
	index = partition(array, left, right)
	if left<index-1:
		quicksort(array, left, index-1)
	if index < right:
		quicksort(array, index, right)

def partition(array, left, right):
	middle = array[int((left+right)/2)]

	while left < right:
		while array[left] <= middle:
			left+=1
		while array[right] > middle:
			right-=1
		temp = array[left]
		array[left] = array[right]
		array[right] = temp
	return left



def largest_sum(array):
	sum_with = array[0]
	sum_without = 0
	for x in range(1, len(array)):
		temp = sum_with
		sum_with = sum_without + array[x]
		sum_without = max(temp, sum_without)
		# print(sum_with)
		# print(sum_without)
		# print('\n')
	return max(sum_with, sum_without)

def binary_ones(num):
	output = []
	for x in range(num+1):
		if x == 0:
			output.append(0)
		elif x%2==1:
			output.append(output[int(x/2)]+1)
		else:
			output.append(output[int(x/2)])
	return output


class ListNode:
	def __init__(self, value, child=None):
		self.value = value
		self.child = child
	def set_value(self, new_value):
		self.value = new_value
	def set_child(self, new_child):
		self.child = new_child

class TreeNode:
	def __init__(self, value, left_child=None, right_child=None):
		self.value = value
		self.left_child = left_child
		self.right_child = right_child
	def set_value(self, new_value):
		self.value = new_value
	def set_left_child(self, new_left_child):
		self.left_child = new_left_child
	def set_right_child(self, new_right_child):
		self.right_child = new_right_child

def odds_first(first_node):
	front_odd = first_node
	current_node = first_node.child
	previous_node = first_node
	is_odd = False
	while current_node != None:
		next_node = current_node.child
		if is_odd:
			front_child = front_odd.child
			current_child = current_node.child
			front_odd.child = current_node
			current_node.child = front_child
			previous_node.child = current_child
			front_odd = current_node
		else:
			previous_node = current_node
		is_odd = not is_odd
		current_node = next_node
	temp = first_node
	while temp != None:
		print(str(temp.value) + '->')
		temp = temp.child

def serialize(head):
	output = [head]
	if head.left_child != None:
		output+=serialize(head.left_child)
	if head.right_child != None:
		output+=serialize(head.right_child)
	return output

def deserialize(array):
	head = array[0]
	found = False
	for x in range(len(array)):
		if array[x].value>head.value and not found:
			index = x
			found = not found
	if not found:
		head.right = None
	elif x == 1:
		head.left = None
	else:
		head.left = deserialize(array[:index])
		head.right = deserialize(array[index:])
	return head

def insertion_sort(array):
	for x in range(1,len(array)):
		current = x
		while array[current]<array[current-1]:
			temp = array[current]
			array[current] = array[current-1]
			array[current-1] = temp
			current -= 1
	return array

def one_away(string1, string2):
	if len(string1) == len(string2):	 
		for x in range(len(string1)):
			if string1[:x] + string1[x+1:] == string2[:x] + string2[x+1:]:
				return True
	if len(string1) - len(string2) == 1:
		for x in range(len(string1)):
			if string1[:x] + string1[x+1:] == string2:
				return True
	if len(string2) - len(string1) == 1:
		for x in range(len(string2)):
			if string2[:x] + string2[x+1:] == string1:
				return True
	return False

def remove_dups(node):
	current_node = node.child
	iterator_node = node
	previous_node = None
	remove_node = False
	while current_node != None:
		while iterator_node != current_node:
			if iterator_node.value == current_node.value:
				remove_node = True
			previous_node = iterator_node
			iterator_node = iterator_node.child
		if remove_node:
			previous_node.child = current_node.child
		current_node = current_node.child
		iterator_node = node
		previous_node = None

def delete_middle_node(node):
	if node.child == None:
		node = None
	else:
		node.value = node.child.value
		node.child = node.child.child

def partition(node, value):

	first_node = node
	current_node = node.child
	previous_node = node
	while current_node != None:
		next_node = current_node.child
		if current_node.value<value:
			previous_node.child = current_node.child
			current_node.child = first_node
			first_node = current_node
		else:
			previous_node = current_node
		current_node = next_node
	return first_node


def create_bst(array):
	if array == []:
		return None
	mid = int(len(array)/2)
	head = TreeNode(array[mid])
	head.left_child = create_bst(array[:mid])
	head.right_child = create_bst(array[mid+1:])
	return head

def longest_substring(string1):
	letters_seen = {}
	longest_substring = ''
	current_substring = ''
	for x in range(len(string1)):
		if string1[x] not in letters_seen.keys():
			current_substring += string1[x]
			letters_seen[string1[x]] = len(current_substring)-1
			if x == len(string1)-1:
				if len(current_substring) > len(longest_substring):
					longest_substring = current_substring
		else:
			if len(longest_substring) < len(current_substring):
				longest_substring = current_substring
			index_x = letters_seen[string1[x]]
			current_substring += string1[x]
			current_substring=current_substring[index_x+1:]
			delete_list = []
			for letter in letters_seen.keys():
				if letters_seen[letter] < index_x:
					delete_list.append(letter)
				else:
					letters_seen[letter] -= index_x
			for letter in delete_list:
				del letters_seen[letter]
	return longest_substring

def is_palindrome(string1):
	if len(string1)<2:
		return True
	if string1[0]!=string1[-1]:
		return False
	return is_palindrome(string1[1:-1])

def lps(string1):
	longest_palindrome = string1[0]
	for x in range(len(string1)-1):
		index = x+1
		while string1.find(string1[x], index) != -1:
			second_index = string1.find(string1[x], index)
			if is_palindrome(string1[x:second_index+1]) and second_index-x+1 > len(longest_palindrome):
				longest_palindrome = string1[x:second_index+1]
			index = string1.find(string1[x], index) + 1
	return longest_palindrome

def zigzag(string, rows):
	row_dict = {}
	row_sequence = []
	output = ''
	for x in range(rows):
		row_dict['row' + str(x)] = ''
		row_sequence.append(x)
	for x in reversed(range(1,rows-1)):
		row_sequence.append(x)
	for x in range(len(string)):
			row_dict['row' + str(row_sequence[x%len(row_sequence)])] += string[x]
	for x in range(rows):
		output += row_dict['row' + str(x)]
	return output

def palindrome_number(num):
	if num < 0:
		return False
	if num < 10:
		return True
	power = 1
	while int(num/10**(power+1)) != 0:
		power += 1
	first_digit = int(num/(10**power))
	last_digit = num%10
	if first_digit != last_digit:
		return False
	new_num = int((num-first_digit*(10**power))/10)
	if power%2==1 and new_num < 10 and new_num != 0:
		return False
	return palindrome_number(new_num)

def most_water(array):
	best_first_index = 0
	best_second_index = 1
	for x in range(2,len(array)):
		first_index_bigger = (x-best_first_index)*min(array[best_first_index],array[x]) > (x-best_second_index)*min(array[best_second_index],array[x])
		if first_index_bigger:
			if (x-best_first_index)*min(array[best_first_index],array[x]) > (best_second_index-best_first_index)*min(array[best_first_index],array[best_second_index]):
				best_second_index = x
		elif (x-best_second_index)*min(array[best_second_index],array[x]) > (best_second_index-best_first_index)*min(array[best_first_index],array[best_second_index]):
			best_first_index = best_second_index
			best_second_index = x
	return (best_second_index - best_first_index)*min(array[best_first_index], array[best_second_index])

def phone_number(num_string):
	data = ['','','abc','def','ghi']
	output_array = []
	for x in data[int(num_string[0])]:
		output_array.append(x)
	print(output_array)
	num_string = num_string[1:]
	while num_string != '':
		new_output = []
		for x in data[int(num_string[0])]:
			for y in output_array:
				new_output.append(y+x)
		num_string = num_string[1:]
		output_array = new_output
	return output_array

def valid_parenthesis(string):
	if string == '':
		return True
	reference = {'[':']','(':')','{':'}'}
	current_index = 0
	while current_index != len(string)-1:
		if string[current_index] in reference.keys() and string[current_index+1] == reference[string[current_index]]:
			return valid_parenthesis(string[:current_index] + string[current_index+2:])
		current_index+=1
	return False

def generate_parenthesis(n):
	if n == 1:
		return ['()']
	list1 = generate_parenthesis(n-1)
	output_array = []
	for string in list1:
		current_index = 0
		string = '(' + string
		while current_index != len(string):
			if string[current_index] == '(':
				if string[:current_index+1]+')'+string[current_index+1:] not in output_array:
					output_array.append(string[:current_index+1]+')'+string[current_index+1:])
			current_index+=1
	return output_array

def swap_pairs(head):
	return_node = head.child
	following_node = return_node.child
	return_node.child = head
	return_node.child.child = following_node

	current_node = following_node
	previous_node = return_node.child
	following_node = current_node.child.child
	while current_node != None:
		previous_node.child = current_node.child
		previous_node.child.child = current_node
		current_node.child = following_node
		previous_node = current_node
		current_node = following_node
		if current_node != None:
			following_node = current_node.child.child
	return return_node


def flip_bit(string):
	longest_run = 0
	current_flipped = 0
	current_not_flipped = 0
	for x in range(len(string)):
		if int(string[x]) == 1:
			current_flipped += 1
			current_not_flipped += 1
		else:
			if current_flipped > longest_run:
				longest_run = current_flipped
			current_flipped = current_not_flipped + 1
			current_not_flipped = 0
		if x == len(string)-1:
			longest_run = max(longest_run, current_flipped)
	return longest_run

def to_binary(num):
	string = ''
	while num != 0:
		if num%2==0:
			string = '0' + string
		else:
			string = '1' + string
		num = int(num/2)
	return string

def from_binary(string):
	num = 0
	for x in range(len(string)):
		power = len(string) - x -1
		num += int(string[x])*(2**power)
	return num

def tripple_step(n):
	if n == 1:
		return 1
	if n == 2:
		return 2
	if n == 3:
		return 7
	list1 = [0,1,2,4]
	i = 4
	while i < n+1:
		list1.append(list1[i-1] +list1[i-2] + list1[i-3])
		i+=1
	return list1[i-1]

def subsets(my_set):
	if my_set == []:
		return [[]]
	output = [[]]
	i = 0
	while i < len(my_set):
		right_half = copy.deepcopy(output)
		for x in right_half:
			x.append(my_set[i])
		output = output + right_half
		i+=1
	return output






















