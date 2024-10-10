// ==UserScript==
// @name         Shortcut for WebLab answer
// @namespace    http://tampermonkey.net/
// @version      1.2
// @description  Makes a get request to see the answer, then refreshes the page
// @author       Teodor Neagoe
// @match        https://weblab.tudelft.nl/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Function to make the GET request
    function makeRequest() {
        const currentUrl = window.location.href;

        // Create the request URL by replacing the last segment and "submission" with "answer"
        const requestUrl = currentUrl.replace(/\/submission\/[^/]+\/$/, '/answer/'); // Regex to match "submission" and the last number

        console.log('Requesting URL:', requestUrl); // Log the request URL for debugging

        // Make the GET request
        fetch(requestUrl, {
            method: 'GET',
            headers: {
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                'Referer': currentUrl,
                'User-Agent': navigator.userAgent,
            },
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.text();
        })
        .then(data => {
            console.log('GET request succeeded:', data);

            // Extract the action URL and form data in one go
            const actionMatch = data.match(/action="([^"]+)"/);
            const formDataMatches = data.match(/<input type="hidden" name="([^"]+)" value="([^"]*)" \/>/g);

            if (actionMatch) {
                const actionUrl = actionMatch[1]; // Extract the action URL
                const formData = {};

                // Extract all hidden form inputs
                if (formDataMatches) {
                    formDataMatches.forEach(match => {
                        const nameMatch = match.match(/name="([^"]+)"/);
                        const valueMatch = match.match(/value="([^"]*)"/);

                        if (nameMatch && valueMatch) {
                            formData[nameMatch[1]] = valueMatch[1]; // Add to form data
                        }
                    });
                }

                console.log('POST Request URL:', actionUrl); // Log the action URL
                console.log('POST Request Data:', formData); // Log the form data

                // Make the POST request
                return fetch(actionUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Referer': actionUrl,
                        'User-Agent': navigator.userAgent,
                    },
                    body: new URLSearchParams(formData).toString(), // Serialize the form data
                });
            } else {
                console.error('Could not find the action URL in the response.');
            }
        })
        .then(response => {
            if (response && !response.ok) {
                throw new Error('Network response for POST was not ok');
            }
            return response.text();
        })
        .then(data => {
            console.log('POST request succeeded:', data);
            // Optionally, handle the response from the POST request
        })
        .catch(error => {
            console.error('There was a problem with the fetch operation:', error);
        });

    }

    // Listen for keydown events
    document.addEventListener('keydown', function(event) {
        // Check if the pressed keys are Ctrl + Alt + A
        if (event.ctrlKey && event.altKey && event.key === 'a') {
            event.preventDefault(); // Prevent the default action if needed
            makeRequest(); // Call the function to make the request
        }
    });
})();

/*
The POST request URL needs to be changed to /assignment.
The Content-Type needs to be set to multipart/form-data, and you will need to format the payload correctly to match this type, including the appropriate boundary in the request.
The payload should include the additional parameter accessAnswerWrapperBasicAssignment_Bool_Placeholder_String_unlock22c21341d54dd438656bf6847deb130a7: 1 and __ajax_runtime_request__: 1.
*/