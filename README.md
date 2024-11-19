# URL Response Checker with Burp Suite Integration

## Description

This script is designed to automate the process of sending discovered URLs (from tools like [Katana](https://github.com/avlidienbrunn/katana) or [Waybackurls](https://github.com/tomnomnom/waybackurls)) to Burp Suite's proxy for further analysis during a bug bounty engagement. The script runs `curl` requests through Burp Suite’s proxy, collects HTTP status codes, and separates URLs that return **403 Forbidden** and **404 Not Found** responses into distinct files. These URLs can later be examined for subdomain takeover opportunities, 404 bypass techniques, or other vulnerabilities.

By using this script, you can efficiently feed large lists of endpoints into Burp Suite for vulnerability scanning while simultaneously saving URLs with specific HTTP status codes for further testing or analysis.

## Features

- **Sends HTTP requests through Burp Suite's proxy:** Automatically feeds discovered URLs into Burp Suite to create a more detailed sitemap.
- **Separate storage for 403 and 404 responses:** URLs returning **403** and **404** status codes are saved to different files for later analysis (e.g., subdomain takeover or 404 bypass tests).
- **Parallel processing:** Uses GNU `parallel` to handle multiple URLs concurrently, speeding up the process.
- **Easy integration with Burp Suite extensions:** While URLs are processed, Burp Suite’s extensions (such as those for SSRF or CORS vulnerabilities) can actively scan and report issues.

## Prerequisites

Before running the script, ensure that you have the following:

- [Burp Suite](https://portswigger.net/burp) running and set up as a proxy on your local machine (default `127.0.0.1:8080`).
- The [parallel](https://www.gnu.org/software/parallel/) utility installed on your system to handle parallel execution of tasks.
- A list of URLs saved in a text file (`all_urls.txt`) that you want to test.
- A working `curl` installation to send requests through the proxy.

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/jadu101/burp_endpoints_feeder.git
    cd burp_endpoints_feeder
    ```

2. Ensure `parallel` and `curl` are installed on your system:

    - On Linux (Debian/Ubuntu):

    ```bash
    sudo apt-get install parallel curl
    ```

    - On macOS:

    ```bash
    brew install parallel curl
    ```

## Usage

1. Create a file called `all_urls.txt` in the same directory as the script. This file should contain the list of URLs you want to test, one URL per line.

2. Run the script:

    ```bash
    ./burp_feeder.sh
    ```

3. After the script finishes, you will see the following:

    - **403_urls.txt**: Contains URLs that returned a **403 Forbidden** response.
    - **404_urls.txt**: Contains URLs that returned a **404 Not Found** response.

4. These files can then be used for additional testing, such as:
   - **Subdomain takeover testing**: Check if any 404 URLs are subdomain takeover candidates.
   - **404 bypass**: Attempt bypass techniques on 404 URLs.

## Example Workflow

1. **Endpoint Discovery:**
   - Use tools like [Katana](https://github.com/avlidienbrunn/katana) or [Waybackurls](https://github.com/tomnomnom/waybackurls) to discover a large set of URLs for a target.
   
   Example command using Waybackurls:
   
   ```bash
   cat target_domain.txt | waybackurls | tee all_urls.txt
   ```
   
3. **Feed to Burp Suite**

Run this script to send the URLs to Burp Suite’s proxy for detailed scanning.

## Further Analysis

After the scan completes, review the **403_urls.txt** and **404_urls.txt** files for URLs that can be tested for vulnerabilities like subdomain takeover or 404 bypass.

## Advanced Usage

- **Custom Proxy Configuration:** If you're using a different proxy configuration for Burp Suite, you can modify the proxy settings in the `process_url` function:

    ```bash
    response=$(curl -x http://<your-proxy-ip>:<your-proxy-port> -I "$url" -s -w "%{http_code}" -o /dev/null)
    ```

- **Adjust Parallelism:** You can change the number of parallel requests by adjusting the `-j` flag in the `parallel` command:

    ```bash
    parallel -j 10 --halt soon,fail=1 'process_url {}'
    ```

- **Additional Status Codes:** You can easily extend the script to handle other HTTP status codes, like 500 or 403, by adding more conditions in the `process_url` function.

## Contributing

If you find any bugs or want to contribute to the development of this script, feel free to fork the repository, create an issue, or submit a pull request.

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.
