#!/usr/bin/env python3
"""
Package.resolved 파일을 파싱하여 오픈소스 라이선스 고지 문서를 생성하는 스크립트
"""

import json
import requests
import re
from pathlib import Path
from typing import Optional, Dict, List
from datetime import datetime


def parse_package_resolved(file_path: str) -> List[Dict]:
    """Package.resolved 파일을 파싱하여 패키지 정보를 추출"""
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    packages = []
    for pin in data.get('pins', []):
        location = pin.get('location', '')
        identity = pin.get('identity', '')
        
        # GitHub URL에서 owner와 repo 추출
        github_match = re.match(r'https://github.com/([^/]+)/([^/]+?)(?:\.git)?$', location)
        if github_match:
            owner, repo = github_match.groups()
            packages.append({
                'identity': identity,
                'location': location,
                'owner': owner,
                'repo': repo,
                'version': pin.get('state', {}).get('version', 'unknown')
            })
    
    return packages


def fetch_license_from_github(owner: str, repo: str) -> Optional[str]:
    """GitHub 리포지토리에서 라이선스 파일 내용을 가져옴"""
    # 가능한 라이선스 파일 이름들
    license_files = ['LICENSE', 'LICENSE.txt', 'LICENSE.md', 'LICENCE', 'LICENCE.txt', 'LICENCE.md']
    
    for license_file in license_files:
        url = f"https://raw.githubusercontent.com/{owner}/{repo}/main/{license_file}"
        
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                return response.text
        except requests.RequestException:
            pass
        
        # main 브랜치가 아닌 master 브랜치도 시도
        url = f"https://raw.githubusercontent.com/{owner}/{repo}/master/{license_file}"
        
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                return response.text
        except requests.RequestException:
            pass
    
    return None


def generate_license_markdown(packages: List[Dict]) -> str:
    """라이선스 정보를 마크다운 형식으로 생성"""
    markdown = "# Open Source License Notices\n\n"
    markdown += f"Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n"
    markdown += "This application uses the following open source packages:\n\n"
    markdown += "---\n\n"
    
    successful_count = 0
    failed_packages = []
    
    for package in packages:
        print(f"Fetching license for {package['identity']}...")
        
        license_content = fetch_license_from_github(package['owner'], package['repo'])
        
        if license_content:
            successful_count += 1
            markdown += f"### {package['identity']}\n\n"
            markdown += f"{package['location']}\n\n"
            markdown += "```\n"
            markdown += license_content.strip()
            markdown += "\n```\n\n"
        else:
            failed_packages.append(package['identity'])
            print(f"  ⚠️  Could not fetch license for {package['identity']}")
    
    # 요약 정보 추가
    markdown += f"\n## Summary\n\n"
    markdown += f"- Total packages: {len(packages)}\n"
    markdown += f"- Licenses fetched: {successful_count}\n"
    
    if failed_packages:
        markdown += f"- Failed to fetch licenses for: {', '.join(failed_packages)}\n"
        markdown += "\n⚠️ Please check these packages manually for license information.\n"
    
    return markdown


def main():
    """메인 실행 함수"""
    # Package.resolved 파일 경로
    package_resolved_path = "../Flitz.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    
    # 파일 존재 확인
    if not Path(package_resolved_path).exists():
        print(f"Error: {package_resolved_path} not found!")
        return
    
    print("Parsing Package.resolved file...")
    packages = parse_package_resolved(package_resolved_path)
    
    if not packages:
        print("No packages found in Package.resolved")
        return
    
    print(f"Found {len(packages)} packages\n")
    
    # 라이선스 정보 수집 및 마크다운 생성
    markdown_content = generate_license_markdown(packages)
    
    # 파일로 저장
    output_file = "OPENSOURCE_LICENSES.md"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(markdown_content)
    
    print(f"\n✅ License notices have been saved to {output_file}")


if __name__ == "__main__":
    main()
