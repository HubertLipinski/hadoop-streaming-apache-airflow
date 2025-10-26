#!/usr/bin/env python3
"""
Mapper do przetwarzania danych lotów.

Czyta dane CSV ze stdin i emituje pary klucz-wartość:
- Key: departure_airport_id_status
- Value: ticket_price,1

Ten format umożliwia poprawne obliczanie średnich w reducer.
"""

import sys

def main():
    for line_num, line in enumerate(sys.stdin, 1):
        line = line.strip()
        
        if not line:
            continue

        # Pomiń linię nagłówka
        if line.startswith('flight_id') or line_num == 1:
            continue

        try:
            fields = line.split(',')

            if len(fields) < 10:
                print(f"Nieprawidłowa liczba pól w linii {line_num}: {len(fields)}", file=sys.stderr)
                continue

            departure_airport_id = fields[2].strip()
            ticket_price_str = fields[7].strip()
            status = fields[9].strip()

            if not departure_airport_id or not ticket_price_str or not status:
                print(f"Puste wymagane pola w linii {line_num}", file=sys.stderr)
                continue

            try:
                ticket_price = float(ticket_price_str)
                if ticket_price < 0:
                    print(f"Ujemna cena biletu w linii {line_num}: {ticket_price}", file=sys.stderr)
                    continue
            except ValueError:
                print(f"Nieprawidłowy format ceny w linii {line_num}: {ticket_price_str}", file=sys.stderr)
                continue

            # Tworzenie złożonego klucza: airport_status
            key = f"{departure_airport_id}_{status}"

            # Format wartości: ticket_price,1 (cena i licznik do obliczenia średniej)
            print(f"{key}\t{ticket_price},1")
            
        except Exception as e:
            print(f"Wyjątek podczas przetwarzania linii {line_num}: {str(e)}", file=sys.stderr)
            continue

if __name__ == "__main__":
    main()