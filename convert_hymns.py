#!/usr/bin/env python3
import json
import re


def convert_hymne_to_json(hymne_text):
    """Convert a single hymne from Dart format to JSON format"""
    
    # Extract number
    number_match = re.search(r"number:\s*'(\d+)'", hymne_text)
    number = number_match.group(1) if number_match else ""
    
    # Extract title
    titre_match = re.search(r"titre:\s*'([^']+)'", hymne_text)
    title = titre_match.group(1) if titre_match else ""
    
    # Extract lyrics (chant) - handle multi-line strings
    chant_match = re.search(r"chant:\s*'([^']*(?:'[^']*)*)'", hymne_text, re.DOTALL)
    if chant_match:
        lyrics = chant_match.group(1)
        # Clean up the lyrics
        lyrics = lyrics.replace("\\t", "").replace("\\n", "\n").replace("\\'", "'")
        # Remove extra spaces and tabs
        lyrics = re.sub(r'\s+', ' ', lyrics).strip()
        # Fix verse numbers
        lyrics = re.sub(r'(\d+)\s+', r'\1\n', lyrics)
    else:
        lyrics = ""
    
    # Extract author
    auteur_match = re.search(r"auteur:\s*'([^']*)'", hymne_text)
    author = auteur_match.group(1) if auteur_match else ""
    
    # Extract composer (musicien)
    musicien_match = re.search(r"musicien:\s*'([^']*)'", hymne_text)
    composer = musicien_match.group(1) if musicien_match else ""
    
    # Extract style
    style_match = re.search(r"style:\s*'([^']*)'", hymne_text)
    style = style_match.group(1) if style_match else ""
    
    # Extract audio files
    soprano_match = re.search(r"soprano:\s*'([^']*)'", hymne_text)
    soprano = soprano_match.group(1) if soprano_match else f"S{number.zfill(3)}"
    
    alto_match = re.search(r"alto:\s*'([^']*)'", hymne_text)
    alto = alto_match.group(1) if alto_match else f"A{number.zfill(3)}"
    
    tenor_match = re.search(r"tenor:\s*'([^']*)'", hymne_text)
    tenor = tenor_match.group(1) if tenor_match else f"T{number.zfill(3)}"
    
    basse_match = re.search(r"basse:\s*'([^']*)'", hymne_text)
    bass = basse_match.group(1) if basse_match else f"B{number.zfill(3)}"
    
    # Create JSON object
    hymne_json = {
        "number": number,
        "title": title,
        "lyrics": lyrics,
        "author": author,
        "composer": composer,
        "style": style,
        "sopranoFile": soprano,
        "altoFile": alto,
        "tenorFile": tenor,
        "bassFile": bass,
        "midiFile": f"h{number}"
    }
    
    return hymne_json

def extract_hymnes_from_dart(file_path):
    """Extract all hymnes from the Dart file and convert to JSON"""
    
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Find the hymnesBank list
    start_marker = "List<Hymne> _hymnesBank = ["
    end_marker = "];"
    
    start_idx = content.find(start_marker)
    if start_idx == -1:
        print("Could not find hymnesBank list")
        return []
    
    start_idx += len(start_marker)
    end_idx = content.find(end_marker, start_idx)
    
    if end_idx == -1:
        print("Could not find end of hymnesBank list")
        return []
    
    hymnes_content = content[start_idx:end_idx]
    
    # Split by Hymne( and process each one
    hymne_parts = hymnes_content.split("Hymne(")
    hymns = []
    
    for i, part in enumerate(hymne_parts[1:], 1):  # Skip first empty part
        try:
            # Find the closing parenthesis for this hymne
            paren_count = 0
            end_pos = 0
            for j, char in enumerate(part):
                if char == '(':
                    paren_count += 1
                elif char == ')':
                    paren_count -= 1
                    if paren_count < 0:
                        end_pos = j
                        break
            
            if end_pos > 0:
                hymne_text = part[:end_pos]
                hymne_json = convert_hymne_to_json(hymne_text)
                if hymne_json["number"]:  # Only add if we have a valid number
                    hymns.append(hymne_json)
                    if i <= 10 or i % 50 == 0:  # Show first 10 and every 50th
                        print(f"Converted hymn {hymne_json['number']}: {hymne_json['title']}")
        except Exception as e:
            print(f"Error converting hymn {i}: {e}")
    
    # Sort by number
    hymns.sort(key=lambda x: int(x["number"]))
    
    return hymns

def main():
    """Main function to convert the hymns"""
    
    input_file = "assets/data/HymnesBrain.dart"
    output_file = "assets/data/hymns.json"
    
    print("Starting hymn conversion...")
    hymns = extract_hymnes_from_dart(input_file)
    
    print(f"\nConverted {len(hymns)} hymns")
    
    # Write to JSON file
    with open(output_file, 'w', encoding='utf-8') as file:
        json.dump(hymns, file, ensure_ascii=False, indent=2)
    
    print(f"JSON file written to {output_file}")
    
    # Print some statistics
    print(f"\nStatistics:")
    print(f"Total hymns: {len(hymns)}")
    if hymns:
        print(f"First hymn: {hymns[0]['number']} - {hymns[0]['title']}")
        print(f"Last hymn: {hymns[-1]['number']} - {hymns[-1]['title']}")

if __name__ == "__main__":
    main()
