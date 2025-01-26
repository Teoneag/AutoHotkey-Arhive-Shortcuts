// ==UserScript==
// @name         Shortcut for getting answer on weblab
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Open a new tab, remove lock, close the tab, and refresh the original tab
// @author       Teodor Neagoe
// @match        https://weblab.tudelft.nl/*
// @grant        none
// ==/UserScript==

(async function() {
    'use strict';

    async function openTabAndRemoveLock() {
        // open answer tab
        const currentUrl = window.location.href;
        const requestUrl = currentUrl.replace(/\/submission\/[^/]+\/$/, '/answer/');
        const newTab = window.open(requestUrl, '_blank');
        await new Promise((resolve) => newTab.onload = resolve); // Wait for the new tab to load

        // Find all the elements that have the 'Yes, remove lock' text
        const anchors = [...newTab.document.body.getElementsByTagName('a')].filter(
            a => a.textContent.includes('🔓 Yes, remove lock')
        );

        // Click on each of the found elements to remove the lock
        for (let anchor of anchors) {
            anchor.click();
        }

        // close the new tab and refresh the original tab
        await new Promise(resolve => setTimeout(resolve, 1)); // await for the lock to be removed
        newTab.close();
        location.reload();
    }

    document.addEventListener('keydown', function(event) { // Ctrl + Alt + A
        if (event.ctrlKey && event.altKey && event.key === 'a') {
            event.preventDefault();
            openTabAndRemoveLock();
        }
    });
})();