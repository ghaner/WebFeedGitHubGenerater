# -*- coding: utf-8 -*-
"""单源测试：只跑 sources.json 中指定 name 的源，用于验证新源不影响其它源。
用法：python test/test_one_source.py xuangutong
"""

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "src"))

import generate_feed as g  # noqa: E402

name = sys.argv[1] if len(sys.argv) > 1 else "xuangutong"

conf = json.load(open(g.CONFIG_PATH, encoding="utf-8"))
cfg = next((c for c in conf["sources"] if c["name"] == name), None)
if cfg is None:
    print("配置中未找到源：%s" % name)
    sys.exit(1)

g.load_local_secrets()
g.process_source(cfg, conf.get("ua", "Mozilla/5.0"), conf.get("timeout", 40))
