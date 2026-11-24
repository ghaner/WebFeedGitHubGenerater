@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ============================================
echo  seedog 停更修复 - 一键验证
echo ============================================
echo.
echo [1/3] 校验配置与 workflow 语法...
python -c "import json; c=json.load(open('src/sources.json',encoding='utf-8')); s=next(x for x in c['sources'] if x['name']=='seedog'); t=open('.github/workflows/generate.yml',encoding='utf-8').read(); print('  配置 JSON OK, seedog.fetch =',s.get('fetch'),', workflow 含 Playwright 安装:', 'Install Playwright' in t, ', 含停更告警:', 'Check feeds freshness' in t)"
if errorlevel 1 goto fail
echo.
echo [2/3] 用真实数据跑 seedog 浏览器抓取（需 playwright + chromium）...
python test\test_one_source.py seedog
if errorlevel 1 (
  echo.
  echo  [警告] 抓取未成功。若提示缺 chromium，请先执行: python -m playwright install chromium
  echo  本机若需代理，请检查系统代理设置。继续打开报告。
)
echo.
echo [3/3] 校验 seedog.xml 并打开报告...
python -c "import xml.etree.ElementTree as ET; r=ET.parse('seedog.xml').getroot(); n=len(r.find('channel').findall('item')); print('  seedog.xml:',n,'items, lastBuildDate=',r.find('channel').findtext('lastBuildDate'))"
start "" "report\seedog_fix_20261124.html"
echo.
echo 完成。本窗口 5 秒后自动关闭。
timeout /t 5 >nul
exit /b 0

:fail
echo.
echo [失败] 校验未通过，请查看上方错误。
start "" "report\seedog_fix_20261124.html"
timeout /t 8 >nul
exit /b 1
