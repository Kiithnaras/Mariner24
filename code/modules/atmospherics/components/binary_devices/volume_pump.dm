/obj/machinery/atmospherics/binary/pump/high_power
	icon = 'icons/atmos/volume_pump.dmi'
	icon_state = "map_off"
	level = 1

	name = "high power gas pump"
	desc = "A pump. Has double the power rating of the standard gas pump."

	power_rating = 15000	//15000 W ~ 20 HP

/obj/machinery/atmospherics/binary/pump/high_power/on
	use_power = POWER_USE_IDLE
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/pump/high_power/New()
	..()
	air1.volume = 2*ATMOS_DEFAULT_VOLUME_PUMP
	air2.volume = 2*ATMOS_DEFAULT_VOLUME_PUMP

/obj/machinery/atmospherics/binary/pump/high_power/on_update_icon()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

// For mapping purposes
/obj/machinery/atmospherics/binary/pump/high_power/on/max_pressure/
	target_pressure = MAX_PUMP_PRESSURE

// A possible variant for Atmospherics distribution feed.
/obj/machinery/atmospherics/binary/pump/high_power/distribution/New()
	..()
	target_pressure = round(3 * ONE_ATMOSPHERE)
	air1.volume = 2*ATMOS_DEFAULT_VOLUME_PUMP
	air2.volume = 2*ATMOS_DEFAULT_VOLUME_PUMP

/obj/machinery/atmospherics/binary/pump/high_power/distribution/on
	use_power = POWER_USE_IDLE
	icon_state = "map_on"