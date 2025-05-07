document.getElementById('SearchText').addEventListener('keyup', function() {
    clearTimeout(window.searchTimeout);
    window.searchTimeout = setTimeout(function() {
        var searchText = document.getElementById('SearchText').value;
        var controlAdd = document.getElementById('Add');
        var controlSearch = document.getElementById('Search');

        controlSearch.disabled = searchText === '';

        // Call AL method to perform search
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('SearchProducts', [searchText]);
    }, 300); // Delay to reduce frequent calls while typing
});
