#!/usr/bin/env python3
"""
MapReduce Mapper for flights data processing.

Reads CSV data from stdin and emits key-value pairs:
- Key: departure_airport_id_status
- Value: ticket_price,1

This format allows proper calculation of averages in the reducer.
"""

import sys

def main():
    for line_num, line in enumerate(sys.stdin, 1):
        line = line.strip()
        
        if not line:
            continue
            
        # Skip header line
        if line.startswith('flight_id') or line_num == 1:
            continue
            
        try:
            fields = line.split(',')
            
            if len(fields) < 10:
                print(f"Invalid number of fields in line {line_num}: {len(fields)}", file=sys.stderr)
                continue
                
            departure_airport_id = fields[2].strip()
            ticket_price_str = fields[7].strip()
            status = fields[9].strip()
            
            if not departure_airport_id or not ticket_price_str or not status:
                print(f"Empty required fields in line {line_num}", file=sys.stderr)
                continue
                
            try:
                ticket_price = float(ticket_price_str)
                if ticket_price < 0:
                    print(f"Negative ticket price in line {line_num}: {ticket_price}", file=sys.stderr)
                    continue
            except ValueError:
                print(f"Invalid ticket price format in line {line_num}: {ticket_price_str}", file=sys.stderr)
                continue
                
            # Create composite key: airport_status
            key = f"{departure_airport_id}_{status}"
            
            # Value format: ticket_price,1 (price and count for average calculation)
            print(f"{key}\t{ticket_price},1")
            
        except Exception as e:
            print(f"Exception processing line {line_num}: {str(e)}", file=sys.stderr)
            continue

if __name__ == "__main__":
    main()