use std::ops::Deref;
use std::sync::atomic::{AtomicUsize, Ordering};

use anyhow::Result;
use clap::Parser;
use filter::subprocess::{Exec, Redirection};
use itertools::Itertools;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

use crate::app::Params;
use crate::paths::AbsPathBuf;
use crate::tools::ctags::CTAGS_HAS_JSON_FEATURE;

/// Prints the tags for a specific file.
#[derive(Parser, Debug, Clone)]
pub struct BufferTags {
    /// Use the raw output format even json output is supported, for testing purpose.
    #[clap(long)]
    force_raw: bool,

    #[clap(long)]
    file: AbsPathBuf,
}

impl BufferTags {
    pub fn run(&self, _params: Params) -> Result<()> {
        let lines = if *CTAGS_HAS_JSON_FEATURE.deref() && !self.force_raw {
            let cmd = build_cmd_in_json_format(self.file.as_ref());
            buffer_tags_lines_inner(cmd, BufferTagInfo::from_ctags_json)?
        } else {
            let cmd = build_cmd_in_raw_format(self.file.as_ref());
            buffer_tags_lines_inner(cmd, BufferTagInfo::from_ctags_raw)?
        };

        for line in lines {
            println!("{}", line);
        }

        Ok(())
    }
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq, Default)]
struct BufferTagInfo {
    name: String,
    pattern: String,
    line: usize,
    kind: String,
}

impl BufferTagInfo {
    /// Returns the display line for BuiltinHandle, no icon attached.
    fn format_buffer_tags(&self, max_name_len: usize) -> String {
        let pattern_len = self.pattern.len();

        let name_line = format!("{}:{}", self.name, self.line);

        let kind = format!("[{}]", self.kind);
        format!(
            "{name_group:<name_group_width$} {kind:<kind_width$} {pattern}",
            name_group = name_line,
            name_group_width = max_name_len + 6,
            kind = kind,
            kind_width = 10,
            pattern = self.pattern[2..pattern_len - 2].trim()
        )
    }

    #[inline]
    fn from_ctags_json(line: &str) -> Option<Self> {
        serde_json::from_str::<Self>(line).ok()
    }

    // The last scope field is optional.
    //
    // Blines	crates/maple_cli/src/app.rs	/^    Blines(command::blines::Blines),$/;"	enumerator	line:39	enum:Cmd
    fn from_ctags_raw(line: &str) -> Option<Self> {
        let mut items = line.split('\t');

        let name = items.next()?.into();
        let _path = items.next()?;

        let mut t = Self {
            name,
            ..Default::default()
        };

        let others = items.join("\t");

        if let Some((tagaddress, kind_line_scope)) = others.rsplit_once(";\"") {
            t.pattern = String::from(&tagaddress[2..]);

            let mut iter = kind_line_scope.split_whitespace();

            t.kind = iter.next()?.into();

            t.line = iter.next().and_then(|s| {
                s.split_once(':')
                    .and_then(|(_, line)| line.parse::<usize>().ok())
            })?;

            Some(t)
        } else {
            None
        }
    }
}

fn build_cmd_in_json_format(file: impl AsRef<std::ffi::OsStr>) -> Exec {
    // Redirect stderr otherwise the warning message might occur `ctags: Warning: ignoring null tag...`
    Exec::cmd("ctags")
        .stderr(Redirection::Merge)
        .arg("--fields=+n")
        .arg("--output-format=json")
        .arg(file)
}

fn build_cmd_in_raw_format(file: impl AsRef<std::ffi::OsStr>) -> Exec {
    // Redirect stderr otherwise the warning message might occur `ctags: Warning: ignoring null tag...`
    Exec::cmd("ctags")
        .stderr(Redirection::Merge)
        .arg("--fields=+Kn")
        .arg("-f")
        .arg("-")
        .arg(file)
}

pub fn buffer_tags_lines(file: impl AsRef<std::ffi::OsStr>) -> Result<Vec<String>> {
    if *CTAGS_HAS_JSON_FEATURE.deref() {
        let cmd = build_cmd_in_json_format(file);
        buffer_tags_lines_inner(cmd, BufferTagInfo::from_ctags_json)
    } else {
        let cmd = build_cmd_in_raw_format(file);
        buffer_tags_lines_inner(cmd, BufferTagInfo::from_ctags_raw)
    }
}

fn buffer_tags_lines_inner(
    cmd: Exec,
    parse_fn: impl Fn(&str) -> Option<BufferTagInfo> + Send + Sync,
) -> Result<Vec<String>> {
    use std::io::BufRead;

    let stdout = cmd.stream_stdout()?;

    let max_name_len = AtomicUsize::new(0);

    let tags = std::io::BufReader::with_capacity(8 * 1024 * 1024, stdout)
        .lines()
        .flatten()
        .par_bridge()
        .filter_map(|s| {
            let maybe_tag_info = parse_fn(&s);
            if let Some(ref tag_info) = maybe_tag_info {
                max_name_len.fetch_max(tag_info.name.len(), Ordering::SeqCst);
            }
            maybe_tag_info
        })
        .collect::<Vec<_>>();

    let max_name_len = max_name_len.into_inner();

    Ok(tags
        .par_iter()
        .map(|s| s.format_buffer_tags(max_name_len))
        .collect::<Vec<_>>())
}