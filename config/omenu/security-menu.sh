#!/bin/bash

run_tool() {
tool="$1"
if command -v "$tool" &>/dev/null; then
kitty -e bash -c "$tool; echo '--- Press enter to close ---'; read"
else
notify-send "Tool not found" "$tool is not installed" --icon=dialog-warning
fi
}

pick_tool() {
category="$1"
tools="$2"
tool=$(printf "%s" "$tools" | rofi -dmenu -p "$category")
[ -n "$tool" ] && run_tool "$tool"
}

main_menu() {
choice=$(printf "🌐 Network\n📡 Wireless\n🦷 Bluetooth\n🔍 Recon\n💉 Exploitation\n🔐 Web\n🔑 Passwords\n🔐 Crypto\n🕵️ Forensics\n📦 Reverse Engineering\n🐛 Fuzzing\n📱 Mobile\n🔧 Misc" | \
rofi -dmenu -p "Security Tools")

case "$choice" in
*Network*)
pick_tool "Network" "$(printf 'nmap\nmasscan\nnetdiscover\narp-scan\nwireshark\ntshark\nbettercap\nnetcat\nsocat\nhping3\ntcpdump\nettercap\ndsniff\nmitmproxy\nresponder\nscapy\nimpacket-scripts\nnbtscan\nonesixtyone\nsnmpwalk\ntelnet\nfping\nzmap\nangryip')"
;;
*Wireless*)
pick_tool "Wireless" "$(printf 'aircrack-ng\nairodump-ng\naireplay-ng\nairmon-ng\nhcxdumptool\nhcxtools\nmdk4\nhostapd\nwifite\nfern-wifi-cracker\nkismet\ncowpatty\nasleap\nairgeddon\nwifiphisher\nkarma')"
;;
*Bluetooth*)
pick_tool "Bluetooth" "$(printf 'bluetoothctl\nbluewalker\nspooftooph\nbtlejuice\nbettercap\nubertooth-util\nhcitool\nhcidump\nbtscanner\ngatttool\nblueranger')"
;;
*Recon*)
pick_tool "Recon" "$(printf 'nmap\ntheharvester\nrecon-ng\namass\nsubfinder\nnuclei\nwhatweb\nnikto\ndirb\ndirbuster\ngobuster\nffuf\nwfuzz\ndnsenum\ndnsrecon\ndmitry\nmaltegoce\nspiderfoot\nshodan\nmetagoofil\nexiftool\nmaltego')"
;;
*Exploitation*)
pick_tool "Exploitation" "$(printf 'msfconsole\nmsfvenom\nsqlmap\nhydra\nmedusa\nncrack\ncaido\nbinwalk\nbuffalo\nexploit-db\nbeef-xss\nroutersploit\nbadsecrets\ncoercer\nnetexec\ncrackmapexec\nevil-winrm\npowersploit')"
;;
*Web*)
pick_tool "Web" "$(printf 'burpsuite\nzaproxy\nnikto\ndirb\ngobuster\nffuf\nwfuzz\nsqlmap\nxsser\ncommix\ncaido\nwapiti\narachni\nw3af\nskipfish\nwhatweb\ncurl\nhttpx\nnuclei')"
;;
*Passwords*)
pick_tool "Passwords" "$(printf 'hashcat\njohn\nhydra\nmedusa\nncrack\ncrunch\ncewl\nrulegen\nrainbowcrack\nophcrack\nsamdump2\nsecretsdump\nmimikatz\nlazagne\ncredentials-harvester')"
;;
*Crypto*)
pick_tool "Crypto" "$(printf 'hashcat\njohn\nopenstego\nsteghide\nstegosuite\noutguess\nstegcracker\nzsteg\nstegsnow\ncryptcat\nxortool\ncyberchef\nrsakey-recovery\nrsactftool')"
;;
*Forensics*)
pick_tool "Forensics" "$(printf 'autopsy\nbinwalk\nvolatility3\nforemost\nscalpel\nwireshark\nnetworkMiner\nmagic-rescue\nrecuperabit\nphotorec\ntestdisk\nstrings\nfile\nexiftool\nstegdetect\ndd\ndcfldd\nfdisk\nmmls')"
;;
*Reverse*)
pick_tool "Reverse Engineering" "$(printf 'radare2\nghidra\ngdb\npwndbg\npeda\nropper\npwntools\nangr\nbinary-ninja\nobjdump\nstrace\nltrace\nnm\nreadelf\nfile\nhexedit\nimhex\niaito')"
;;
*Fuzzing*)
pick_tool "Fuzzing" "$(printf 'afl\nafl++\nboofuzz\nradamsa\nhonggfuzz\nlibafl\npeach\nffuf\nwfuzz\ngobuster\nferoxbuster')"
;;
*Mobile*)
pick_tool "Mobile" "$(printf 'apktool\njadx\ndex2jar\nandriller\nmobsf\nfrida\nobjection\nadb\nmitmproxy\nburpsuite\nqark\napkleaks')"
;;
*Misc*)
pick_tool "Misc" "$(printf 'metasploit\nset\nveil\nthefatrat\nnbtscan\nenum4linux\nldapdomaindump\nbloodhound\nneo4j\npowerview\nlinpeas\nwinpeas\npspy\nlinux-exploit-suggester')"
;;
esac
}

main_menu

