$file = 'src\main\webapp\WEB-INF\views\property\detail.jsp'
$content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$insertBefore = "`r`n                `</body>"
$leafletScript = @"

                             <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
                             <script>
                             (function() {
                               var lat = `${propertyLat};
                               var lng = `${propertyLng};
                               var nearby = `${nearbyMapDataJson};
                               var map = L.map('propertyMap', { center: [lat, lng], zoom: 13, scrollWheelZoom: false });
                               L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { attribution: 'OpenStreetMap contributors', maxZoom: 19 }).addTo(map);
                               var blueIcon = L.divIcon({ className: '', html: '<div style="width:18px;height:18px;background:#1A73E8;border:3px solid white;border-radius:50%;box-shadow:0 2px 8px rgba(26,115,232,0.5);"></div>', iconSize: [18,18], iconAnchor: [9,9], popupAnchor: [0,-12] });
                               var orangeIcon = L.divIcon({ className: '', html: '<div style="width:14px;height:14px;background:#F59E0B;border:2px solid white;border-radius:50%;box-shadow:0 2px 6px rgba(245,158,11,0.4);"></div>', iconSize: [14,14], iconAnchor: [7,7], popupAnchor: [0,-10] });
                               L.marker([lat, lng], { icon: blueIcon }).addTo(map).bindPopup('<div style="min-width:160px;padding:4px;"><b>`${property.title}</b><br><span style="color:#1a73e8;font-weight:700;">&#8377;`${property.price}</span></div>').openPopup();
                               nearby.forEach(function(np) { L.marker([np.lat,np.lng],{icon:orangeIcon}).addTo(map).bindPopup('<div style="min-width:150px;padding:4px;"><b>'+np.title+'</b><br><span style="color:#1a73e8;font-weight:700;">&#8377;'+Number(np.price).toLocaleString('en-IN')+'</span><br><a href="/properties/'+np.id+'" style="color:#1a73e8;font-size:12px;">View &#8594;</a></div>'); });
                             })();
                             </script>
"@

$newContent = $content.Replace($insertBefore, $leafletScript + $insertBefore)
[System.IO.File]::WriteAllText($file, $newContent, [System.Text.Encoding]::UTF8)
Write-Host "Done. New size: $($newContent.Length)"
