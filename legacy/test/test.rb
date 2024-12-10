str = 'Eins_Zwei'


print '1: '
puts str.gsub(/(_)/, '\1')
print '2: '
puts str.gsub(/(_)/, '\\1')
print '3: '
puts str.gsub(/(_)/, '\\\1')
print '4: '
puts str.gsub(/(_)/, '\\\\1')
print '5: '
puts str.gsub(/(_)/, '\\\\\1')
print '6: '
puts str.gsub(/(_)/, '\\\\\\1')
print '7: '
puts str.gsub(/(_)/, '\\\\\\\1')
print '8: '
puts str.gsub(/(_)/, '\\\\\\\\1')
print '9: '
puts str.gsub(/(_)/, '\\\\\\\\\1')
print '10: '
puts str.gsub(/(_)/, '\\\\\\\\\\1')