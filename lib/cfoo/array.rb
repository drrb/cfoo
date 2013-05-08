class Array
    def join_adjacent_strings
        return clone if empty?
        self[1..-1].inject([first]) do |combined_parts, part|
            previous = combined_parts.pop
            if previous.class == String && part.class == String
                combined_parts << previous + part
            else
                combined_parts << previous << part
            end
        end
    end
end
