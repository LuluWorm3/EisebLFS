var tableSearch = document.getElementById('tableSearch');
if (tableSearch) {
    tableSearch.addEventListener('keyup', function() {
        var filter = this.value.toUpperCase();
        var rows = document.querySelectorAll('table tbody tr');
        rows.forEach(function(row) {
            var text = row.textContent.toUpperCase();
            row.style.display = text.indexOf(filter) > -1 ? '' : 'none';
        });
    });
}

document.querySelectorAll('table thead th').forEach(function(th, colIndex) {
    th.style.cursor = 'pointer';
    th.addEventListener('click', function() {
        var table = th.closest('table');
        var tbody = table.querySelector('tbody');
        var rows = Array.from(tbody.querySelectorAll('tr'));
        var ascending = th.classList.contains('sorted-asc');
        table.querySelectorAll('th').forEach(function(h) { h.classList.remove('sorted-asc', 'sorted-desc'); });
        th.classList.add(ascending ? 'sorted-desc' : 'sorted-asc');
        rows.sort(function(a, b) {
            var aVal = a.cells[colIndex].textContent.trim().toLowerCase();
            var bVal = b.cells[colIndex].textContent.trim().toLowerCase();
            var aNum = parseFloat(aVal.replace(/[^0-9.-]/g, ''));
            var bNum = parseFloat(bVal.replace(/[^0-9.-]/g, ''));
            if (!isNaN(aNum) && !isNaN(bNum)) return ascending ? (bNum - aNum) : (aNum - bNum);
            return ascending ? bVal.localeCompare(aVal) : aVal.localeCompare(bVal);
        });
        rows.forEach(function(row) { tbody.appendChild(row); });
    });
});
