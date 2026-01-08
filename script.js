window.addEventListener('message', function(event) {
    let data = event.data;

    // Affiche ou Cache tout le HUD
    if (data.action === "toggleHud") {
        document.body.style.display = data.show ? "block" : "none";
    }

    // Mise à jour des Stats
    if (data.action === "updateHud") {
        $("#id").text(data.id);
        $("#online").text(data.online);
        $("#time").text(data.time);
        $("#job").text(data.job + " - " + data.grade);
        $("#cash").text(data.cash + " $");
        $("#bank").text(data.bank + " $");
        $("#postal").text(data.postal);

        $("#health").text(Math.round(data.health));
        $("#hunger").text(Math.round(data.hunger));
        $("#thirst").text(Math.round(data.thirst));
        $("#stamina").text(Math.round(data.stamina));

        // Gestion Armure
        if (data.armor > 0) {
            $("#armor-container").show();
            $("#armor").text(Math.round(data.armor));
        } else {
            $("#armor-container").hide();
        }

        // Gestion Micro
        if (data.talking) {
            $("#mic-icon").addClass("mic-talking");
        } else {
            $("#mic-icon").removeClass("mic-talking");
        }
    }

    // Mise à jour HUD Voiture
    if (data.action === "carHud") {
        if (data.show) {
            $("#carHud").fadeIn(200);
            $("#speed").text(data.speed);
            $("#fuel").text(Math.round(data.fuel));
        } else {
            $("#carHud").fadeOut(200);
        }
    }

    // Mise à jour HUD Arme
    if (data.action === "updateAmmo") {
        if (data.show) {
            $("#ammoHud").fadeIn(200);
            $("#ammo-count").text(data.ammo);
        } else {
            $("#ammoHud").fadeOut(200);
        }
    }
});
