require 'active_support/core_ext/module/delegation'
require 'todo-txt/task'
require 'redpomo/tracker'

module Todo
  class Task

    def self.projects_regex
       /(?:\s+|^)\+[\w\-]+/
    end

  end
end

module Redpomo
  class Task

    delegate :orig, to: :@task

    ISSUES_REGEXP = /(?:\s+|^)#[0-9]+/

    def initialize(list, text)
      @task = Todo::Task.new(text)
      @list = list
    end

    def context
      @task.contexts.map do |context|
        context.gsub /^@/, ''
      end.first
    end

    def project
      @task.projects.map do |context|
        context.gsub /^\+/, ''
      end.first
    end

    def issue
      orig.scan(ISSUES_REGEXP).map(&:strip).map do |issue|
        issue.gsub(/^#/, '').to_i
      end.first
    end

    def text
      @task.text.gsub(ISSUES_REGEXP, '').strip
    end

    def close_issue!(message = nil)
      tracker.close_issue!(issue, message)
    end

    def done!
      @list.remove!(self)
    end

    def open_in_browser!
      require 'launchy'
      Launchy.open(url)
    end

    def start_pomodoro!
      require 'applescript'
      command = 'tell application "Pomodoro" to start "'
      command << orig
      command << '"'
      AppleScript.execute(command)
    end

    def url
      return nil unless tracker.present?
      if issue.present?
        "#{tracker.base_url}/issues/#{issue}"
      elsif project.present?
        "#{tracker.base_url}/projects/#{project}"
      else
        "#{tracker.base_url}/projects/#{tracker.default_project}"
      end
    end

    def tracker
      Tracker.find(context)
    end

  end
end

