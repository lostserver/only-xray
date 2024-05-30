#!/bin/bash

dtdir="/root/date"
initd="/etc/init.d"
logp="/root/logp"
jamup2="/root/jam2_up.sh"
jamup="/root/jamup.sh"
nmfl="$(basename "$0")"
scver="3.5"

function nyetop() {
	stopvpn="${nmfl}: Stopping"
	echo -e "${stopvpn} VPN tunnels jika tersedia."
	logger "${stopvpn} VPN tunnels jika tersedia."
	if [[ -f "$initd"/openclash ]] && [[ $(uci -q get openclash.config.enable) == "1" ]]; then "$initd"/openclash stop && echo -e "${stopvpn} OpenClash"; fi
	if [[ -f "$initd"/zerotier ]] && [[ $(uci -q get zerotier.sample_config.enabled) == "1" ]]; then "$initd"/zerotier stop && echo -e "${stopvpn} Zerotier"; fi
}

function nyetart() {
	startvpn="${nmfl}: Restarting"
	echo -e "${startvpn} VPN tunnels jika tersedia."
	logger "${startvpn} VPN tunnels jika tersedia."
	if [[ -f "$initd"/openclash ]] && [[ $(uci -q get openclash.config.enable) == "1" ]]; then "$initd"/openclash restart && echo -e "${startvpn} OpenClash"; fi
	if [[ -f "$initd"/zerotier ]] && [[ $(uci -q get zerotier.sample_config.enabled) == "1" ]]; then
		echo -e "${startvpn} Zerotier in 5 detik"
		logger "${startvpn} Zerotier in 5 detik"
		sleep 5
		"$initd"/zerotier restart
		echo -e "${startvpn} Zerotier DONE pek!"
	else
		echo -e "${startvpn} Zerotier tidak tersedia, karena tidak terpakai"
		logger "${startvpn} Zerotier tidak tersedia, karena tidak terpakai"
	fi
}

function ngecurl() {
	curl -si "$cv_type" | grep Date > "$dtdir"
	echo -e "${nmfl}: Gas $cv_type sebagai server waktu."
	logger "${nmfl}: Gas $cv_type sebagai server waktu."
}

function sandal() {
    hari=$(cat "$dtdir" | cut -b 12-13)
    bulan=$(cat "$dtdir" | cut -b 15-17)
    tahun=$(cat "$dtdir" | cut -b 19-22)
    jam=$(cat "$dtdir" | cut -b 24-25)
    menit=$(cat "$dtdir" | cut -b 26-31)

    case $bulan in
        "Jan")
           bulan="01"
            ;;
        "Feb")
            bulan="02"
            ;;
        "Mar")
            bulan="03"
            ;;
        "Apr")
            bulan="04"
            ;;
        "May")
            bulan="05"
            ;;
        "Jun")
            bulan="06"
            ;;
        "Jul")
            bulan="07"
            ;;
        "Aug")
            bulan="08"
            ;;
        "Sep")
            bulan="09"
            ;;
        "Oct")
            bulan="10"
            ;;
        "Nov")
            bulan="11"
            ;;
        "Dec")
            bulan="12"
            ;;
        *)
           return

    esac

	date -u -s "$tahun"."$bulan"."$hari"-"$jam""$menit" > /dev/null 2>&1
	echo -e "${nmfl}: Set time to [ $(date) ]"
	logger "${nmfl}: Set time to [ $(date) ]"
}

if [[ "$1" == "update" ]]; then
	echo -e "${nmfl}: Updating script..."
	echo -e "${nmfl}: Downloading script update..."
	curl -sL raw.githubusercontent.com/kulo-sinten/jam-hp-stb/main/jam.sh > "$jamup"
	chmod +x "$jamup"
	sed -i 's/\r$//' "$jamup"
	cat << "EOF" > "$jamup2"
#!/bin/bash
# Updater script sync jam otomatis berdasarkan bug/domain/url isp
jamsh='/usr/bin/jam.sh'
jamup='/root/jamup.sh'
[[ -e "$jamup" ]] && [[ -f "$jamsh" ]] && rm -f "$jamsh" && mv "$jamup" "$jamsh"
[[ -e "$jamup" ]] && [[ ! -f "$jamsh" ]] && mv "$jamup" "$jamsh"
echo -e 'jam.sh: Update done...'
chmod +x "$jamsh"
EOF
	sed -i 's/\r$//' "$jamup2"
	chmod +x "$jamup2"
	bash "$jamup2"
	[[ -f "$jamup2" ]] && rm -f "$jamup2" && echo -e "${nmfl}: update file cleaned up!" && logger "${nmfl}: update file cleaned up!"
elif [[ "$1" =~ "http://" ]]; then
	cv_type="$1"
elif [[ "$1" =~ "https://" ]]; then
	cv_type=$(echo -e "$1" | sed 's|https|http|g')
elif [[ "$1" =~ [.] ]]; then
	cv_type=http://"$1"
else
	echo -e "=> Tambakan domain dibelakaang script!."
	echo -e "${nmfl}: Kesalahan URL/Bug/Domain!. Read https://github.com/kulo-sinten/jam-hp-stb/tree/main/README.md for details."
	logger "${nmfl}: Kesalahan URL/Bug/Domain!. Read https://github.com/kulo-sinten/jam-hp-stb/tree/main/README.md for details."
fi

function ngepink() {
	if [[ $(curl -si ${cv_type} | grep -c 'Date:') == "1" ]]; then
		echo -e "${nmfl}: Konek ${cv_type} tersedia, melanjutkan tugas"
		logger "${nmfl}: Konek ${cv_type} tersedia, melanjutkan tugas"
	else 
		if [[ "$2" == "cron" ]]; then
			echo -e "${nmfl}: mode cron terdeteksi dan koneksi ke ${cv_type} tersedia, melanjutkan tugas"
			logger "${nmfl}: mode cron terdeteksi dan koneksi ke ${cv_type} tersedia, melanjutkan tugas"
			nyetop
			nyetart
		else
			echo -e "${nmfl}: Konek ke ${cv_type} tidak tersedia plugin"
			logger "${nmfl}: Konek ke ${cv_type} tidak tersedian plugin"
			sleep 3
			ngepink
		fi
	fi
}

if [[ ! -z "$cv_type" ]]; then
	# Script Version
	echo -e "${nmfl}: Script v${scver}"
	logger "${nmfl}: Script v${scver}"
	
	# Runner
	if [[ "$2" == "cron" ]]; then
		ngepink
	else
		nyetop
		ngepink
		ngecurl
		sandal
		nyetart
	fi

	# Cleaning files
	[[ -f "$logp" ]] && rm -f "$logp" && echo -e "${nmfl}: logp cleaned up!" && logger "${nmfl}: logp cleaned up!"
	[[ -f "$dtdir" ]] && rm -f "$dtdir" && echo -e "${nmfl}: tmp dir cleaned up!" && logger "${nmfl}: tmp dir cleaned up!"
	[[ -f "$jamup2" ]] && rm -f "$jamup2" && echo -e "${nmfl}: update file cleaned up!" && logger "${nmfl}: update file cleaned up!"
else
	echo -e "=> Tambakan domain dibelakaang script!."
	echo -e "${nmfl}: Kesalahan URL/Bug/Domain!. Read https://github.com/kulo-sinten/jam-hp-stb/tree/main/README.md for details."
	logger "${nmfl}: Kesalahan URL/Bug/Domain!. Read https://github.com/kulo-sinten/jam-hp-stb/tree/main/README.md for details."
fi
