#!/bin/bash

# Files to store 403 and 404 responses
file_403="./403_urls.txt"
file_404="./404_urls.txt"

# Clear the files if they exist (to start fresh)
> "$file_403"
> "$file_404"

# Function to handle the curl request and response code
process_url() {
    local url=$1
    local response

    # Send the request through Burp Suite's proxy and capture the response
    response=$(curl -x http://127.0.0.1:8080 -I "$url" -s -w "%{http_code}" -o /dev/null)

    # Check if the response code is 403 or 404 and store the URL in the respective file
    if [ "$response" -eq 403 ]; then
        echo "$url" >> "$file_403"
    elif [ "$response" -eq 404 ]; then
        echo "$url" >> "$file_404"
    fi

    # Optional: Log the response for debugging
    echo "URL: $url - Response: $response"
}

# Export function for parallel execution
export -f process_url
export file_403
export file_404

# Run the parallel command, passing the URL list and processing them in parallel
cat all_urls.txt | parallel -j 10 --halt soon,fail=1 'process_url {}'

echo "URLs with 403 responses are stored in $file_403"
echo "URLs with 404 responses are stored in $file_404"
