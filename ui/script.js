window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "toggleHud") {
        document.body.style.display = data.show ? "block" : "none";
    }

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

        // NOUVEAU : Mise à jour de la voix en permanence
        $("#voice-range").text(data.voiceLabel);

        // Micro
        if (data.talking) {
            $("#mic-icon").addClass("mic-talking");
        } else {
            $("#mic-icon").removeClass("mic-talking");
        }

        // Armure
        if (data.armor > 0) {
            $("#armor-container").show();
            $("#armor").text(Math.round(data.armor));
        } else {
            $("#armor-container").hide();
        }
    }

    // Gestion du compteur de vitesse et de l'état du véhicule
    if (data.action === "carHud") {
        if (data.show) {
            $("#carHud").fadeIn(200);
            $("#speed").text(data.speed);
            $("#fuel").text(Math.round(data.fuel));

            let maxSpeed = 250;
            let currentSpeed = data.speed > maxSpeed ? maxSpeed : data.speed;
            let strokeDashoffset = 283 - (283 * (currentSpeed / maxSpeed));
            $("#speed-progress").css("stroke-dashoffset", strokeDashoffset);

            if (currentSpeed > 130) {
                $("#speed-progress").css("stroke", "#e74c3c"); // Rouge
            } else {
                $("#speed-progress").css("stroke", "#3498db"); // Bleu
            }

            let damageThreshold = 800.0;
            if (data.vehHealth <= damageThreshold) {
                $("#vehDamageIcon").removeClass("dmg-good").addClass("dmg-bad");
            } else {
                $("#vehDamageIcon").removeClass("dmg-bad").addClass("dmg-good");
            }

        } else {
            $("#carHud").fadeOut(200);
        }
    }

    if (data.action === "updateAmmo") {
        if (data.show) {
            $("#ammoHud").fadeIn(200);
            $("#ammo-count").text(data.ammo);
        } else {
            $("#ammoHud").fadeOut(200);
        }
    }
});